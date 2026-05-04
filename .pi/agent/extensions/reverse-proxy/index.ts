import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { appendFileSync, existsSync, readFileSync } from "node:fs";
import http, { type IncomingMessage, type ServerResponse } from "node:http";
import https from "node:https";
import { homedir } from "node:os";
import { dirname, isAbsolute, resolve } from "node:path";
import { execFileSync } from "node:child_process";

type HeaderMap = Record<string, string>;

type MtlsConfig = {
  cert?: string;
  key?: string;
  ca?: string;
  passphrase?: string;
  rejectUnauthorized?: boolean;
};

type ProviderProxyConfig = {
  upstream?: string;
  headers?: HeaderMap;
  mtls?: MtlsConfig;
};

type ReverseProxyConfig = {
  listen?: {
    host?: string;
    port?: number;
  };
  providers?: Record<string, ProviderProxyConfig>;
};

type ProviderRuntime = {
  name: string;
  upstream: URL;
  headers: HeaderMap;
  agent?: https.Agent;
};

type ModelsJson = {
  providers?: Record<string, { baseUrl?: string }>;
};

const defaultConfigPath = resolve(homedir(), ".pi/agent/reverse-proxy.json");
const defaultModelsPaths = [
  resolve(homedir(), ".pi/agent/models.json"),
  resolve(process.cwd(), ".pi/agent/models.json"),
];
const logPath = "/tmp/pi-reverse-proxy.log";

function log(message: string) {
  appendFileSync(logPath, `${new Date().toISOString()} ${message}\n`);
}

function expandPath(path: string): string {
  if (path === "~") return homedir();
  if (path.startsWith("~/")) return resolve(homedir(), path.slice(2));
  return isAbsolute(path) ? path : resolve(process.cwd(), path);
}

function getConfigPath(): string {
  const configured = process.env.PI_REVERSE_PROXY_CONFIG?.trim();
  return configured ? expandPath(configured) : defaultConfigPath;
}

function isPlainObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function readJsonFile(path: string): unknown {
  return JSON.parse(readFileSync(path, "utf8"));
}

function readConfig(path: string): ReverseProxyConfig {
  const parsed = readJsonFile(path);
  if (!isPlainObject(parsed)) throw new Error(`${path} must contain a JSON object`);
  return parsed as ReverseProxyConfig;
}

function findConfiguredBaseUrl(provider: string): string | undefined {
  for (const path of defaultModelsPaths) {
    if (!existsSync(path)) continue;
    const parsed = readJsonFile(path) as ModelsJson;
    const baseUrl = parsed.providers?.[provider]?.baseUrl;
    if (typeof baseUrl === "string" && baseUrl.trim()) return baseUrl;
  }
  return undefined;
}

function resolveValue(value: string): string {
  if (value.startsWith("!")) {
    return execFileSync("bash", ["-lc", value.slice(1)], { encoding: "utf8" }).trimEnd();
  }
  return process.env[value] ?? value;
}

function resolveHeaders(headers: HeaderMap | undefined): HeaderMap {
  const resolved: HeaderMap = {};
  for (const [name, value] of Object.entries(headers ?? {})) {
    resolved[name] = resolveValue(value);
  }
  return resolved;
}

function readOptionalFile(path: string | undefined): Buffer | undefined {
  return path ? readFileSync(expandPath(path)) : undefined;
}

function createMtlsAgent(mtls: MtlsConfig | undefined): https.Agent | undefined {
  if (!mtls) return undefined;
  return new https.Agent({
    cert: readOptionalFile(mtls.cert),
    key: readOptionalFile(mtls.key),
    ca: readOptionalFile(mtls.ca),
    passphrase: mtls.passphrase ? resolveValue(mtls.passphrase) : undefined,
    rejectUnauthorized: mtls.rejectUnauthorized ?? true,
  });
}

function providerSegment(name: string): string {
  return encodeURIComponent(name);
}

function localBaseUrl(host: string, port: number, runtime: ProviderRuntime): string {
  const pathname = runtime.upstream.pathname.replace(/\/$/, "");
  return `http://${host}:${port}/${providerSegment(runtime.name)}${pathname}`;
}

function createRuntimeMap(
  configPath: string,
  config: ReverseProxyConfig,
): Map<string, ProviderRuntime> {
  const providers = config.providers ?? {};
  const runtimes = new Map<string, ProviderRuntime>();

  for (const [name, provider] of Object.entries(providers)) {
    const upstream = provider.upstream ?? findConfiguredBaseUrl(name);
    if (!upstream) {
      throw new Error(
        `${configPath}: provider '${name}' needs an upstream or a matching baseUrl in ~/.pi/agent/models.json`,
      );
    }

    runtimes.set(name, {
      name,
      upstream: new URL(upstream),
      headers: resolveHeaders(provider.headers),
      agent: createMtlsAgent(provider.mtls),
    });
  }

  return runtimes;
}

function splitProvider(pathname: string): { provider: string; restPath: string } | undefined {
  const match = pathname.match(/^\/([^/]+)(\/.*)?$/);
  if (!match) return undefined;
  return {
    provider: decodeURIComponent(match[1]),
    restPath: match[2] ?? "/",
  };
}

function buildTargetUrl(runtime: ProviderRuntime, restPath: string, search: string): URL {
  const normalized = restPath.startsWith("/") ? restPath : `/${restPath}`;
  return new URL(`${normalized}${search}`, runtime.upstream.origin);
}

function proxyRequest(
  runtimes: Map<string, ProviderRuntime>,
  req: IncomingMessage,
  res: ServerResponse,
) {
  const originalUrl = new URL(req.url ?? "/", "http://localhost");
  const route = splitProvider(originalUrl.pathname);
  const runtime = route ? runtimes.get(route.provider) : undefined;

  if (!route || !runtime) {
    res.writeHead(404, { "content-type": "text/plain" });
    res.end("Unknown reverse proxy provider route\n");
    return;
  }

  const target = buildTargetUrl(runtime, route.restPath, originalUrl.search);
  log(`${req.method ?? "GET"} /${route.provider}${route.restPath}${originalUrl.search} -> ${target.toString()}`);
  const headers: http.OutgoingHttpHeaders = { ...req.headers, ...runtime.headers };
  delete headers.host;
  delete headers.connection;
  delete headers["proxy-connection"];

  const client = target.protocol === "https:" ? https : http;
  const upstreamReq = client.request(
    {
      protocol: target.protocol,
      hostname: target.hostname,
      port: target.port,
      path: `${target.pathname}${target.search}`,
      method: req.method,
      headers,
      agent: target.protocol === "https:" ? runtime.agent : undefined,
    },
    (upstreamRes) => {
      res.writeHead(upstreamRes.statusCode ?? 502, upstreamRes.statusMessage, upstreamRes.headers);
      upstreamRes.pipe(res);
    },
  );

  upstreamReq.on("error", (error) => {
    log(`ERROR ${target.toString()}: ${error.message}`);
    if (res.headersSent) {
      res.destroy(error);
      return;
    }
    res.writeHead(502, { "content-type": "text/plain" });
    res.end(`Reverse proxy upstream error: ${error.message}\n`);
  });

  req.on("aborted", () => upstreamReq.destroy());
  req.pipe(upstreamReq);
}

async function listen(server: http.Server, host: string, port: number): Promise<void> {
  await new Promise<void>((resolveListen, rejectListen) => {
    server.once("error", rejectListen);
    server.listen(port, host, () => {
      server.off("error", rejectListen);
      resolveListen();
    });
  });
}

export default async function (pi: ExtensionAPI) {
  const configPath = getConfigPath();
  if (!existsSync(configPath)) return;

  log(`loading config ${configPath}`);
  const config = readConfig(configPath);
  const host = config.listen?.host ?? "127.0.0.1";
  const port = config.listen?.port ?? 18189;
  const runtimes = createRuntimeMap(configPath, config);
  if (runtimes.size === 0) return;

  const server = http.createServer((req, res) => proxyRequest(runtimes, req, res));
  await listen(server, host, port);
  log(`listening http://${host}:${port}`);

  const registerOverrides = (ctx?: ExtensionContext) => {
    for (const runtime of runtimes.values()) {
      const baseUrl = localBaseUrl(host, port, runtime);
      pi.registerProvider(runtime.name, { baseUrl });
      log(`override ${runtime.name}: ${runtime.upstream.toString()} -> ${baseUrl}`);
    }
    ctx?.ui.notify(`Reverse proxy active on http://${host}:${port}`, "info");
  };

  registerOverrides();

  pi.on("session_start", async (_event, ctx) => {
    // Reapply after model resources settle so custom models keep their localhost route.
    registerOverrides(ctx.hasUI ? ctx : undefined);
  });

  pi.on("session_shutdown", async () => {
    log("shutdown");
    await new Promise<void>((resolveClose) => server.close(() => resolveClose()));
    for (const runtime of runtimes.values()) runtime.agent?.destroy();
  });
}
