# Terminal Sync Workflows

All commands use `$DOTFILES` (see SKILL.md for resolution).

## terminal push

1. Show changes:
```bash
git -C $DOTFILES status
git -C $DOTFILES diff
```
2. Stage only changed config files, commit, push:
```bash
git -C $DOTFILES add <changed-files>
git -C $DOTFILES commit -m "update: <brief description>"
git -C $DOTFILES push
```

## terminal pull

1. Pull:
```bash
git -C $DOTFILES pull
```
2. Run setup (idempotent — creates missing symlinks, skips existing ones):
```powershell
pwsh -File $DOTFILES/setup.ps1
```
3. Run bootstrap if pull included new tools in `bootstrap.ps1`:
```powershell
pwsh -File $DOTFILES/bootstrap.ps1
```
4. Remind user to restart terminal for changes to take effect.
