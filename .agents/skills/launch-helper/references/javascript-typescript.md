# JavaScript and TypeScript Launch Configs

## Detection

Treat the repo as JS/TS when `package.json`, `tsconfig.json`, `.js`, `.jsx`, `.ts`, or `.tsx` files are primary. Inspect:

- `package.json` scripts for `dev`, `start`, `serve`, `build`, `test`
- Framework/build markers: `vite.config.*`, `next.config.*`, `nuxt.config.*`, `webpack.config.*`, `esbuild`, `tsx`, `ts-node`, `nodemon`
- Whether the app is browser, Node, or both
- Existing `.vscode/tasks.json`

## Vite Browser App

Use a task to start the dev server, then attach a browser debugger. Keep the port from the repo's config or documented script; Vite's default is `5173`.

`launch.json`:

```jsonc
{
  "name": "Debug Vite app",
  "type": "chrome",
  "request": "launch",
  "url": "http://localhost:5173",
  "webRoot": "${workspaceFolder}/src",
  "preLaunchTask": "npm: dev"
}
```

`tasks.json` task when absent:

```jsonc
{
  "label": "npm: dev",
  "type": "npm",
  "script": "dev",
  "isBackground": true,
  "problemMatcher": {
    "owner": "vite",
    "pattern": {
      "regexp": "^$"
    },
    "background": {
      "activeOnStart": true,
      "beginsPattern": ".*",
      "endsPattern": "Local:.*http://localhost:"
    }
  }
}
```

## Other Browser Builders

For Next, Nuxt, webpack dev server, Parcel, custom Express dev servers, or other builders, prefer the repo's documented `package.json` script and configured port:

```jsonc
{
  "name": "Debug browser app",
  "type": "chrome",
  "request": "launch",
  "url": "http://localhost:<port>",
  "webRoot": "${workspaceFolder}",
  "preLaunchTask": "npm: <script>"
}
```

Create the matching npm task only if it does not already exist:

```jsonc
{
  "label": "npm: <script>",
  "type": "npm",
  "script": "<script>",
  "isBackground": true,
  "problemMatcher": []
}
```

If the dev server does not have a reliable readiness message, tell the user the browser config may need the server started manually instead of pretending the task can always detect readiness.

## Node App

For plain Node:

```jsonc
{
  "name": "Debug Node",
  "type": "node",
  "request": "launch",
  "program": "${workspaceFolder}/<entrypoint>",
  "cwd": "${workspaceFolder}",
  "console": "integratedTerminal"
}
```

For TypeScript executed through `tsx`:

```jsonc
{
  "name": "Debug TypeScript",
  "type": "node",
  "request": "launch",
  "runtimeExecutable": "npx",
  "runtimeArgs": ["tsx", "<entrypoint>"],
  "cwd": "${workspaceFolder}",
  "console": "integratedTerminal"
}
```

For npm scripts:

```jsonc
{
  "name": "Debug npm script",
  "type": "node",
  "request": "launch",
  "runtimeExecutable": "npm",
  "runtimeArgs": ["run", "<script>"],
  "cwd": "${workspaceFolder}",
  "console": "integratedTerminal"
}
```

## Notes

- Prefer `"type": "node"` for server-side code and `"type": "chrome"` or `"type": "msedge"` for browser debugging, matching existing configs.
- Use `webRoot: "${workspaceFolder}"` when source files are not under `src`.
- Do not add a dev-server task if the user only asked to debug a Node script.
- Verify with `npm run build`, `npm test`, or `npm run <script> -- --help` when practical.
