# dotfiles

Personal bash environment: prompt, shell helpers ("cogs"), nvim and tmux config.
Installed by `install_dotfiles.bash`.

## Hard rules

- **Never push to `main`/`master`.** Feature branch + PR, always. Open the PR,
  report the URL, stop — **only the human merges.**
- **Conventional Commits** (`feat:`, `fix:`, `chore:`, …). Never hand-bump a version.
- **`pre-commit` is the gate.** Run `pre-commit run --files <changed>` before
  declaring a change done, and report the result.
- **`mise` provisions the toolchain** (`mise install`). New worktrees need `mise trust`.
- Plan every non-trivial task. If the plan fails, restart planning.

## Workflow

Default branch is `master`. CI (`ci.yml`) runs `pre-commit run --all-files` plus a
syntax check of the install script; `docker-publish.yml` builds and cosign-signs
an image on pushes to `master` and on a daily cron.

## Architecture

- `cogs/` — 17 sourced bash modules, one per topic: `git`, `k8s`, `flux`, `java`,
  `tmux`, `neovim`, `network`, `osx`, `linux`, `security`, `text`, `navigation`,
  `completion`, `env`, `gtd`, `mgr`, `leftovers`
- `bin/` — standalone scripts (`brew_update.sh`, `md_cal.sh`, `weather_update.sh`)
- `config/` — nvim, and config for the prompt and cog loader
- `dotfiles/` — the files that get linked into `$HOME` (gitconfig, inputrc,
  tmux.conf.local, .hammerspoon)
- `packages/` — brew config, keyboard layouts, bootstrap

## Commands

```bash
mise install
bash -n install_dotfiles.bash          # what CI checks
pre-commit run --files <changed files>
pre-commit run --all-files
```

There is no test suite.

## Gotchas

- **There are no submodules.** nvim plugins are vim-plug managed: declared in
  `config/nvim/init.vim`, cloned at runtime into `config/nvim/plugged/`, which
  is gitignored. Third-party plugin code is never tracked in this repo.
- The README says `bin/install_dotfiles.sh`; the tracked file is
  `install_dotfiles.bash`.
- Bash standards, enforced by pre-commit: `#!/usr/bin/env bash`, `set -e`, `[[`
  not `[`, `$()` not backticks, `local` in functions, no emojis, 2-space indent.
  shellcheck runs on `*.bash`; shfmt with `-w -s -i 2`.
- Personal, untracked notes belong in `CLAUDE.local.md`, which is gitignored.
