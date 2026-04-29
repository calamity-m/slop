# slop

Dumb slop. Dotfiles held together with symlinks and vibes. Neovim config, bash extensions, and a growing pile of AI agent skills

## Quick Start

```bash
git clone <this-repo> ~/code/slop
./install.sh
```

That's it. The script symlinks everything into place:

- `~/.config/skills` — AI agent skills (also wired into `~/.claude/skills` and `~/.codex/skills`)
- `~/.config/agents` — agent instruction files
- `~/.config/nvim` — neovim config
- `~/.config/zellij` — zellij config and layouts
- `~/.config/peanutbutter` — peanutbutter config and snippets
- `~/.config/peanutbutter-private/snippets` — private peanutbutter snippets directory
- `~/.bashrc.d` — shell extensions, auto-sourced
- `~/.local/share/forgit` — forgit checkout sourced by `~/.bashrc.d/zz-forgit.sh`

It won't nuke your existing config unless you pass `--force`, at which point you've been warned.

## Prerequisites

The installer mostly symlinks config. It does not install the tools those configs expect, except for cloning `forgit` when `git` is available.

Update runbooks assume direct installs land in `~/.local/bin`; run `mkdir -p ~/.local/bin ~/.local/opt` first and adjust the destination if a tool is package-manager managed on your machine. For `.zip` assets, use `unzip <asset> -d "$tmp"` instead of `tar -xf ... -C "$tmp"`.

Core tools:

| Tool | Used for | Where to get it | Update runbook |
| --- | --- | --- | --- |
| `bash` | `install.sh` and `~/.bashrc.d` shell extensions | <https://www.gnu.org/software/bash/> | `sudo apt update && sudo apt install --only-upgrade bash` or equivalent package manager |
| `git` | cloning this repo and installing `forgit` | <https://git-scm.com/> | `sudo apt update && sudo apt install --only-upgrade git` or equivalent package manager |
| `fzf` | shell completion and picker-backed helpers | <https://github.com/junegunn/fzf> | `git -C ~/.fzf pull && ~/.fzf/install` if installed from git, otherwise use package manager |
| `zoxide` | shell directory jumping integration | <https://github.com/ajeetdsouza/zoxide> | `tmp=$(mktemp -d); curl -L <release-archive> -o "$tmp/zoxide.tar"; tar -xf "$tmp/zoxide.tar" -C "$tmp"; install "$(find "$tmp" -type f -name zoxide | head -1)" ~/.local/bin/zoxide` |
| `eza` | `ll`, `la`, and `tree` aliases | <https://github.com/eza-community/eza> | `tmp=$(mktemp -d); curl -L <release-archive> -o "$tmp/eza.tar"; tar -xf "$tmp/eza.tar" -C "$tmp"; install "$(find "$tmp" -type f -name eza | head -1)" ~/.local/bin/eza` |
| `peanutbutter` | snippet expansion and shell integration | <https://github.com/calamity-m/peanutbutter/releases> | `tmp=$(mktemp -d); curl -L <release-archive> -o "$tmp/pb.tar"; tar -xf "$tmp/pb.tar" -C "$tmp"; install "$(find "$tmp" -type f -name peanutbutter | head -1)" ~/.local/bin/peanutbutter` |

### Neovim

The Neovim config uses `vim.pack`, `vim.lsp.enable`, `nvim-lspconfig`, `conform.nvim`, `fzf-lua`, and `tree-sitter-manager.nvim`. Use a recent `nvim` with those built-ins available; this config is currently used with `NVIM v0.12.2`.

Editor basics:

| Tool | Used for | Where to get it | Update runbook |
| --- | --- | --- | --- |
| `nvim` | the editor config and `vi` alias | <https://neovim.io/> | `tmp=$(mktemp -d); curl -L <nvim-linux-archive> -o "$tmp/nvim.tar"; tar -xf "$tmp/nvim.tar" -C "$tmp"; rm -rf ~/.local/opt/nvim; mv "$(find "$tmp" -maxdepth 1 -type d -name 'nvim-*' | head -1)" ~/.local/opt/nvim; ln -sf ~/.local/opt/nvim/bin/nvim ~/.local/bin/nvim` |
| `fzf` | `fzf-lua` native picker backend | <https://github.com/junegunn/fzf> | `git -C ~/.fzf pull && ~/.fzf/install` if installed from git, otherwise use package manager |
| `rg` / ripgrep | `fzf-lua` live grep and global search | <https://github.com/BurntSushi/ripgrep> | `tmp=$(mktemp -d); curl -L <release-archive> -o "$tmp/rg.tar"; tar -xf "$tmp/rg.tar" -C "$tmp"; install "$(find "$tmp" -type f -name rg | head -1)" ~/.local/bin/rg` |
| C compiler/toolchain | building installed Tree-sitter parsers when needed | your OS package manager, Xcode Command Line Tools, or `build-essential` | `sudo apt update && sudo apt install --only-upgrade build-essential` or equivalent package manager |

Configured LSP binaries:

| LSP config | Binary command | Languages | Where to get it | Update runbook |
| --- | --- | --- | --- | --- |
| `rust_analyzer` | `rust-analyzer` | Rust | <https://rust-analyzer.github.io/> | `rustup update && rustup component add rust-analyzer` |
| `gopls` | `gopls` | Go, `go.mod`, `go.work`, Go templates | <https://pkg.go.dev/golang.org/x/tools/gopls> | `go install golang.org/x/tools/gopls@latest` |
| `lua_ls` | `lua-language-server` | Lua | <https://luals.github.io/> | `tmp=$(mktemp -d); curl -L <release-archive> -o "$tmp/lua-ls.tar"; tar -xf "$tmp/lua-ls.tar" -C "$tmp"; root=$(dirname "$(dirname "$(find "$tmp" -type f -path '*/bin/lua-language-server' | head -1)")"); rm -rf ~/.local/opt/lua-language-server; cp -a "$root" ~/.local/opt/lua-language-server; ln -sf ~/.local/opt/lua-language-server/bin/lua-language-server ~/.local/bin/lua-language-server` |
| `ty` | `ty server` | Python | <https://github.com/astral-sh/ty> | `uv tool install --force ty` |
| `oxfmt` | `oxfmt --lsp` | JS/TS, JSON, YAML, HTML, CSS, Markdown, and related web files | <https://oxc.rs/docs/guide/usage/formatter.html> | `npm install -g oxfmt@latest` |
| `helm_ls` | `helm_ls serve` | Helm templates and Helm values YAML | <https://github.com/mrjosh/helm-ls> | `tmp=$(mktemp -d); curl -L <release-archive> -o "$tmp/helm-ls.tar"; tar -xf "$tmp/helm-ls.tar" -C "$tmp"; install "$(find "$tmp" -type f -name helm_ls | head -1)" ~/.local/bin/helm_ls` |
| `tombi` | `tombi lsp` | TOML | <https://tombi-toml.github.io/tombi/> | `uv tool install --force tombi` |
| `marksman` | `marksman server` | Markdown | <https://github.com/artempyanykh/marksman> | `tmp=$(mktemp -d); curl -L <release-asset> -o "$tmp/marksman"; install "$tmp/marksman" ~/.local/bin/marksman` |

Configured formatters:

| Formatter | Filetypes | Where to get it | Update runbook |
| --- | --- | --- | --- |
| `stylua` | Lua | <https://github.com/JohnnyMorganz/StyLua> | `cargo install stylua --locked --force` |
| `goimports`, `gofmt` | Go | <https://pkg.go.dev/golang.org/x/tools/cmd/goimports> and <https://go.dev/> | `go install golang.org/x/tools/cmd/goimports@latest`; `gofmt` updates with Go itself |
| `ruff` | Python | <https://docs.astral.sh/ruff/> | `uv tool install --force ruff` |
| `rustfmt` | Rust | <https://github.com/rust-lang/rustfmt> | `rustup update && rustup component add rustfmt` |
| `oxfmt` | JS/TS, JSON/JSONC, Vue | <https://oxc.rs/docs/guide/usage/formatter.html> | `npm install -g oxfmt@latest` |
| `tombi` | TOML | <https://tombi-toml.github.io/tombi/> | `uv tool install --force tombi` |
| `kdlfmt` | KDL, except `config.kdl` | <https://github.com/hougesen/kdlfmt> | `cargo install kdlfmt --locked --force` |

Tree-sitter parsers are configured for bash, Lua, Python, Rust, JavaScript, Zig, Go, Markdown, JSON, TOML, TypeScript, TSX, Go templates, Helm, and YAML.

Optional workflow tools:

| Tool | Used for | Where to get it | Update runbook |
| --- | --- | --- | --- |
| `rg` / ripgrep | Docker helper filtering and peanutbutter snippets | <https://github.com/BurntSushi/ripgrep> | `tmp=$(mktemp -d); curl -L <release-archive> -o "$tmp/rg.tar"; tar -xf "$tmp/rg.tar" -C "$tmp"; install "$(find "$tmp" -type f -name rg | head -1)" ~/.local/bin/rg` |
| `zellij` | terminal workspace config and layouts | <https://zellij.dev/> | `tmp=$(mktemp -d); curl -L <release-archive> -o "$tmp/zellij.tar"; tar -xf "$tmp/zellij.tar" -C "$tmp"; install "$(find "$tmp" -type f -name zellij | head -1)" ~/.local/bin/zellij` |
| `docker` | Docker shell helpers and peanutbutter variables | <https://docs.docker.com/get-docker/> | update via Docker Desktop, Docker Engine packages, or your OS package manager |
| `kubectl` | Kubernetes shell completions and peanutbutter variables | <https://kubernetes.io/docs/tasks/tools/> | `tmp=$(mktemp -d); curl -L <stable-version-url>/bin/linux/amd64/kubectl -o "$tmp/kubectl"; install "$tmp/kubectl" ~/.local/bin/` |
| `glab` | `.scripts/pipeline-dashboard.sh` | <https://gitlab.com/gitlab-org/cli> | `tmp=$(mktemp -d); curl -L <release-archive> -o "$tmp/glab.tar"; tar -xf "$tmp/glab.tar" -C "$tmp"; install "$(find "$tmp" -type f -path '*/bin/glab' | head -1)" ~/.local/bin/glab` |
| `jq` | `.scripts/pipeline-dashboard.sh` JSON parsing | <https://jqlang.org/> | `tmp=$(mktemp -d); curl -L <release-asset> -o "$tmp/jq"; install "$tmp/jq" ~/.local/bin/jq` |
| `forgit` | Git shortcuts sourced from `~/.local/share/forgit` | <https://github.com/wfxr/forgit> | `git -C "${FORGIT_HOME:-$HOME/.local/share/forgit}" pull --ff-only` |

## Why

Because google was a tool once, then stackoverflow, and now this. Why not slop it together with my actual dotfiles?
