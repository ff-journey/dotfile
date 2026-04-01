#!/bin/bash
# frps.sh — frp server: start/stop with optional auto-start (systemd)
# Usage: bash frps.sh start | stop

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SCRIPT_DIR/frps.toml"
PID_FILE="$SCRIPT_DIR/frps.pid"
LOG_FILE="$SCRIPT_DIR/frps.log"
SERVICE_NAME="frps-dotfiles"

# ── Locate frps binary ──────────────────────────────────────────────────────
FRPS_BIN="$(command -v frps 2>/dev/null || echo "")"
if [ -z "$FRPS_BIN" ]; then
    for c in /usr/local/bin/frps /usr/bin/frps; do
        [ -f "$c" ] && FRPS_BIN="$c" && break
    done
fi
if [ -z "$FRPS_BIN" ]; then
    echo "ERROR: frps binary not found. Install frp or add it to PATH."
    exit 1
fi

# ── Check config ─────────────────────────────────────────────────────────────
if [ ! -f "$CONFIG" ]; then
    echo "ERROR: $CONFIG not found."
    echo "  Copy frps.toml.example to frps.toml and fill in auth.token"
    exit 1
fi

case "$1" in
  start)
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            echo "frps is already running (PID: $PID)"
            exit 0
        fi
        rm -f "$PID_FILE"
    fi

    echo "Starting frps..."
    nohup "$FRPS_BIN" -c "$CONFIG" >> "$LOG_FILE" 2>&1 &
    PID=$!
    echo "$PID" > "$PID_FILE"
    echo "  frps started (PID: $PID)"

    # ── Create systemd service for auto-start ────────────────────────
    SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
    if [ ! -f "$SERVICE_FILE" ]; then
        echo "  Creating systemd service '$SERVICE_NAME'..."
        sudo tee "$SERVICE_FILE" > /dev/null <<UNIT
[Unit]
Description=frp server (dotfiles managed)
After=network.target

[Service]
Type=simple
ExecStart=$FRPS_BIN -c $CONFIG
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT
        sudo systemctl daemon-reload
        sudo systemctl enable "$SERVICE_NAME"
        echo "  Systemd service enabled."
        echo "  Note: the process was started directly this time."
        echo "  On next boot, systemd will manage it. Or run:"
        echo "    sudo systemctl start $SERVICE_NAME"
    else
        echo "  Systemd service already exists."
    fi
    ;;

  stop)
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            echo "Stopping frps (PID: $PID)..."
            kill "$PID"
            echo "  frps stopped."
        else
            echo "  Process $PID not running."
        fi
        rm -f "$PID_FILE"
    else
        echo "  frps is not running (no PID file)."
    fi

    # Also stop systemd service if active
    if systemctl is-active "$SERVICE_NAME" &>/dev/null; then
        echo "  Stopping systemd service..."
        sudo systemctl stop "$SERVICE_NAME"
    fi

    # Remove systemd service
    SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
    if [ -f "$SERVICE_FILE" ]; then
        echo "  Removing systemd service '$SERVICE_NAME'..."
        sudo systemctl disable "$SERVICE_NAME"
        sudo rm -f "$SERVICE_FILE"
        sudo systemctl daemon-reload
        echo "  Systemd service removed."
    fi
    ;;

  *)
    echo "Usage: bash frps.sh start | stop"
    exit 1
    ;;
esac
