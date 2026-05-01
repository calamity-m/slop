# Python Launch Configs

## Detection

Treat the repo as Python when it has `pyproject.toml`, `requirements.txt`, `setup.py`, `uv.lock`, `Pipfile`, or requested Python files. Inspect:

- Console script entrypoints in `pyproject.toml`
- Common app files: `main.py`, `app.py`, package `__main__.py`
- Framework markers: `manage.py`, FastAPI/Flask imports, pytest config
- Existing venv conventions: `.venv/`, `uv`, Poetry, Pipenv

## Patterns

Debug the current file:

```jsonc
{
  "name": "Debug Python file",
  "type": "debugpy",
  "request": "launch",
  "program": "${file}",
  "console": "integratedTerminal"
}
```

Debug a module entrypoint:

```jsonc
{
  "name": "Debug Python module",
  "type": "debugpy",
  "request": "launch",
  "module": "<package_or_module>",
  "console": "integratedTerminal",
  "cwd": "${workspaceFolder}"
}
```

Debug Django:

```jsonc
{
  "name": "Debug Django",
  "type": "debugpy",
  "request": "launch",
  "program": "${workspaceFolder}/manage.py",
  "args": ["runserver"],
  "django": true,
  "console": "integratedTerminal"
}
```

Debug FastAPI with Uvicorn:

```jsonc
{
  "name": "Debug FastAPI",
  "type": "debugpy",
  "request": "launch",
  "module": "uvicorn",
  "args": ["<module>:<app>", "--reload"],
  "console": "integratedTerminal",
  "cwd": "${workspaceFolder}"
}
```

## Notes

- Do not hardcode interpreter paths unless the user asks. VS Code Python interpreter selection usually belongs to workspace/user settings.
- Prefer `"type": "debugpy"` for modern Python debugger configs.
- If `.env` already exists or `.env.example` clearly documents variables, add `"envFile": "${workspaceFolder}/.env"`.
- Verify with a cheap import/compile check such as `python -m py_compile <entrypoint>` when practical.
