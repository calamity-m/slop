import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { resolve } from "node:path";

type HeaderMap = Record<string, string>;
type ProviderHeadersConfig = Record<string, HeaderMap>;

const defaultConfigPath = resolve(homedir(), ".pi/agent/provider-headers.json");

function getConfigPath(): string {
	const configured = process.env.PI_PROVIDER_HEADERS_CONFIG?.trim();
	return configured ? resolve(configured) : defaultConfigPath;
}

function isPlainObject(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null && !Array.isArray(value);
}

function parseConfig(contents: string, path: string): ProviderHeadersConfig {
	const parsed = JSON.parse(contents) as unknown;
	if (!isPlainObject(parsed)) {
		throw new Error(`${path} must contain a JSON object`);
	}

	const config: ProviderHeadersConfig = {};
	for (const [provider, headers] of Object.entries(parsed)) {
		if (!isPlainObject(headers)) {
			throw new Error(`${path}: provider '${provider}' must map to an object of HTTP headers`);
		}

		const headerMap: HeaderMap = {};
		for (const [name, value] of Object.entries(headers)) {
			if (typeof value !== "string") {
				throw new Error(`${path}: header '${provider}.${name}' must be a string`);
			}
			headerMap[name] = value;
		}

		config[provider] = headerMap;
	}

	return config;
}

export default function (pi: ExtensionAPI) {
	const configPath = getConfigPath();
	if (!existsSync(configPath)) return;

	const config = parseConfig(readFileSync(configPath, "utf8"), configPath);
	for (const [provider, headers] of Object.entries(config)) {
		pi.registerProvider(provider, { headers });
	}
}
