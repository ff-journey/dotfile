# Terminal Sync Workflows

All commands use `$DOTFILES` (see SKILL.md for resolution).

## terminal push

Trigger: `terminal push`, `push dotfiles`, `同步terminal配置`

1. Show changes:
```bash
git -C $DOTFILES status
git -C $DOTFILES diff
```
2. Stage only changed files, commit, push:
```bash
git -C $DOTFILES add <changed-files>
git -C $DOTFILES commit -m "update: <brief description>"
git -C $DOTFILES push
```

## terminal pull

Trigger: `terminal pull`, `pull dotfiles`, `拉取terminal配置`

1. Pull:
```bash
git -C $DOTFILES pull
```
2. Run bootstrap (installs any new dependencies):
```powershell
pwsh -File $DOTFILES/bootstrap.ps1
```
3. Run setup (ensures symlinks):
```powershell
pwsh -File $DOTFILES/setup.ps1
```
4. Remind user to restart terminal.
