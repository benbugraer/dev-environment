# Development Environment

Portable, public-safe dotfiles for my active development setup:

- Ghostty terminal
- Herdr workspace/agent multiplexer
- Pi coding-agent settings, packages, skills, and resource directories
- Neovim with LazyVim

The repository is designed to be cloned on a new machine and installed in one step, while avoiding private credentials and generated runtime state.

## Quick start

```bash
git clone <your-repo-url> dev-environment
cd dev-environment
scripts/check-secrets.sh
scripts/install.sh
```

By default the installer creates symlinks and backs up existing files under:

```text
~/.dev-environment-backups/<timestamp>/
```

If you prefer physical copies instead of symlinks:

```bash
scripts/install.sh --copy
```

To preview changes without touching your system:

```bash
scripts/install.sh --dry-run
```

To ask Pi to reconcile/install the configured Pi packages after linking settings:

```bash
scripts/install.sh --install-pi-packages
```

## Repository layout

```text
config/
  ghostty/                 Ghostty configuration
  herdr/                   Herdr user-maintained configuration only
  nvim/                    Neovim / LazyVim configuration
pi/
  agent/
    settings.json          Public-safe Pi user settings
    skills/                Bundled Pi skills
    extensions/            Conventional Pi extension directory
    prompts/               Conventional Pi prompt-template directory
    themes/                Conventional Pi theme directory
scripts/
  install.sh               Symlink/copy installer with backups
  check-secrets.sh         Lightweight public-repo safety check
```

## What is intentionally not stored

Do **not** commit credentials or generated local state. In particular, this repo excludes:

- Pi `auth.json`, API keys, OAuth tokens, and provider credentials
- Herdr sockets, logs, sessions, generated plugin directories, plugin lock files, and plaintext credential stores
- `.env` files
- Neovim runtime/cache/data directories

Provider credentials should stay in your shell environment, OS credential store, or the relevant tool's private auth file.

## Pi configuration

The install script links only selected Pi agent files into `~/.pi/agent`:

- `settings.json`
- `skills/`
- `extensions/`
- `prompts/`
- `themes/`

It does **not** replace the whole Pi agent directory, so private files such as `auth.json`, sessions, and model authentication remain outside this repo.

Configured Pi packages:

- `npm:pi-web-access`
- `npm:@plannotator/pi-extension`

Skills are stored under `pi/agent/skills` using Pi's conventional skill discovery layout. The extension, prompt, and theme directories are present so additional resources can be added without changing the installer.

## Herdr notes

Only hand-edited configuration is tracked:

- `config.toml`
- `config-gpui.local.toml`
- `plugins.portable.json` as a machine-independent record of Herdr plugins to reinstall

Generated files such as `config-gpui.toml`, `session.json`, logs, sockets, downloaded plugins, and plugin lock files are intentionally ignored.

## Requirements

Install the tools you want to use before running the configuration:

- Ghostty
- Herdr
- Pi (`npm install -g --ignore-scripts @earendil-works/pi-coding-agent` or the official installer)
- Neovim 0.10+ recommended for LazyVim
- Git
- Node.js 22.19+ for Pi

## Updating this repo from your machine

After changing local configuration, copy only safe files back into this repo. Avoid copying entire application state directories.

```bash
rsync -a --delete --exclude='.git' ~/.config/nvim/ config/nvim/
cp ~/.config/ghostty/config.ghostty config/ghostty/config.ghostty
cp ~/.config/herdr/config.toml config/herdr/config.toml
cp ~/.config/herdr/config-gpui.local.toml config/herdr/config-gpui.local.toml
rsync -a --delete ~/.pi/agent/skills/ pi/agent/skills/
scripts/check-secrets.sh
```

Review the diff before committing.
