# Python hooks

## Detection

Files matching `**/*.py` or presence of `pyproject.toml`, `setup.py`, `requirements.txt`.

## Hooks

```toml
# Lint and format with ruff (replaces flake8, isort, black)
[[repos]]
repo = "https://github.com/astral-sh/ruff-pre-commit"
rev = "<latest-tag>"
hooks = [
    { id = "ruff", args = ["--fix"] },
    { id = "ruff-format" },
]
```

## Notes

- `ruff` covers linting (flake8-compatible) and auto-fixes where safe.
- `ruff-format` is the formatter (black-compatible).
- If the project already uses black or flake8 separately, prefer ruff as a drop-in replacement — it's faster and requires only one hook block.
- If mypy or pyright is already configured in the project, it can be added but runs slow in pre-commit; better left to CI.
