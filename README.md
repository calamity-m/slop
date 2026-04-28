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

Core tools:

| Tool | Used for | Where to get it |
| --- | --- | --- |
| `bash` | `install.sh` and `~/.bashrc.d` shell extensions | <https://www.gnu.org/software/bash/> |
| `git` | cloning this repo and installing `forgit` | <https://git-scm.com/> |
| `fzf` | shell completion and picker-backed helpers | <https://github.com/junegunn/fzf> |
| `zoxide` | shell directory jumping integration | <https://github.com/ajeetdsouza/zoxide> |
| `eza` | `ll`, `la`, and `tree` aliases | <https://github.com/eza-community/eza> |
| `peanutbutter` | snippet expansion and shell integration | <https://github.com/calamity-m/peanutbutter/releases> |

### Neovim

The Neovim config uses `vim.pack`, `vim.lsp.enable`, `nvim-lspconfig`, `conform.nvim`, `fzf-lua`, and `tree-sitter-manager.nvim`. Use a recent `nvim` with those built-ins available; this config is currently used with `NVIM v0.12.2`.

Editor basics:

| Tool | Used for | Where to get it |
| --- | --- | --- |
| `nvim` | the editor config and `vi` alias | <https://neovim.io/> |
| `fzf` | `fzf-lua` native picker backend | <https://github.com/junegunn/fzf> |
| `rg` / ripgrep | `fzf-lua` live grep and global search | <https://github.com/BurntSushi/ripgrep> |
| C compiler/toolchain | building installed Tree-sitter parsers when needed | your OS package manager, Xcode Command Line Tools, or `build-essential` |

Configured LSP binaries:

| LSP config | Binary command | Languages | Where to get it |
| --- | --- | --- | --- |
| `rust_analyzer` | `rust-analyzer` | Rust | <https://rust-analyzer.github.io/> |
| `gopls` | `gopls` | Go, `go.mod`, `go.work`, Go templates | <https://pkg.go.dev/golang.org/x/tools/gopls> |
| `lua_ls` | `lua-language-server` | Lua | <https://luals.github.io/> |
| `ty` | `ty server` | Python | <https://github.com/astral-sh/ty> |
| `oxfmt` | `oxfmt --lsp` | JS/TS, JSON, YAML, HTML, CSS, Markdown, and related web files | <https://oxc.rs/docs/guide/usage/formatter.html> |
| `helm_ls` | `helm_ls serve` | Helm templates and Helm values YAML | <https://github.com/mrjosh/helm-ls> |
| `tombi` | `tombi lsp` | TOML | <https://tombi-toml.github.io/tombi/> |
| `marksman` | `marksman server` | Markdown | <https://github.com/artempyanykh/marksman> |

Configured formatters:

| Formatter | Filetypes | Where to get it |
| --- | --- | --- |
| `stylua` | Lua | <https://github.com/JohnnyMorganz/StyLua> |
| `goimports`, `gofmt` | Go | <https://pkg.go.dev/golang.org/x/tools/cmd/goimports> and <https://go.dev/> |
| `ruff` | Python | <https://docs.astral.sh/ruff/> |
| `rustfmt` | Rust | <https://github.com/rust-lang/rustfmt> |
| `oxfmt` | JS/TS, JSON/JSONC, Vue | <https://oxc.rs/docs/guide/usage/formatter.html> |
| `tombi` | TOML | <https://tombi-toml.github.io/tombi/> |
| `kdlfmt` | KDL, except `config.kdl` | <https://github.com/hougesen/kdlfmt> |

Tree-sitter parsers are configured for bash, Lua, Python, Rust, JavaScript, Zig, Go, Markdown, JSON, TOML, TypeScript, TSX, Go templates, Helm, and YAML.

Optional workflow tools:

| Tool | Used for | Where to get it |
| --- | --- | --- |
| `rg` / ripgrep | Docker helper filtering and peanutbutter snippets | <https://github.com/BurntSushi/ripgrep> |
| `zellij` | terminal workspace config and layouts | <https://zellij.dev/> |
| `docker` | Docker shell helpers and peanutbutter variables | <https://docs.docker.com/get-docker/> |
| `kubectl` | Kubernetes shell completions and peanutbutter variables | <https://kubernetes.io/docs/tasks/tools/> |
| `glab` | `.scripts/pipeline-dashboard.sh` | <https://gitlab.com/gitlab-org/cli> |
| `jq` | `.scripts/pipeline-dashboard.sh` JSON parsing | <https://jqlang.org/> |
| `forgit` | Git shortcuts sourced from `~/.local/share/forgit` | <https://github.com/wfxr/forgit> |

## Why

Because google was a tool once, then stackoverflow, and now this. Why not slop it together with my actual dotfiles?
