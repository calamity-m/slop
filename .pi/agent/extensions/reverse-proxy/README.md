# Reverse Proxy Pi Extension

Starts a localhost reverse proxy and rewrites selected Pi providers to route through it.
The proxy can add headers and use client TLS certificates when connecting to the real upstream.

This is a local gateway, not a transparent MITM proxy.

## Config

Default path:

```text
~/.pi/agent/reverse-proxy.json
```

Override path:

```bash
PI_REVERSE_PROXY_CONFIG=/path/to/reverse-proxy.json pi
```

Example with explicit upstreams:

```json
{
  "listen": {
    "host": "127.0.0.1",
    "port": 18189
  },
  "providers": {
    "corp-openai": {
      "upstream": "https://corp-provider.example.com/v1",
      "headers": {
        "X-Team": "platform",
        "X-Corp-Token": "CORP_PROXY_TOKEN",
        "X-Secret": "!op read 'op://vault/item/secret'"
      },
      "mtls": {
        "cert": "~/.config/pi-certs/client.crt",
        "key": "~/.config/pi-certs/client.key",
        "ca": "~/.config/pi-certs/ca.crt",
        "rejectUnauthorized": true
      }
    }
  }
}
```

If `upstream` is omitted, the extension reads the provider `baseUrl` from `~/.pi/agent/models.json` or `.pi/agent/models.json`:

```json
{
  "providers": {
    "corp-openai": {
      "headers": {
        "X-Team": "platform"
      },
      "mtls": {
        "cert": "~/.config/pi-certs/client.crt",
        "key": "~/.config/pi-certs/client.key"
      }
    }
  }
}
```

With normal Pi model config:

```json
{
  "providers": {
    "corp-openai": {
      "baseUrl": "https://corp-provider.example.com/v1",
      "api": "openai-completions",
      "apiKey": "CORP_API_KEY",
      "models": [{ "id": "llama3.1:8b" }, { "id": "qwen2.5-coder:7b" }]
    }
  }
}
```

The extension rewrites Pi's provider base URL to a local route like:

```text
http://127.0.0.1:18189/corp-openai/v1
```

Requests are forwarded to:

```text
https://corp-provider.example.com/v1
```

## Header value resolution

Header values support:

- environment variables: `"CORP_PROXY_TOKEN"`
- shell commands: `"!op read 'op://vault/item/secret'"`
- literal strings: used when no matching environment variable exists

## Notes

- Bind to `127.0.0.1`; do not expose the proxy on a public interface.
- The proxy streams responses and does not intentionally buffer provider output.
- `/reload` restarts the proxy and reloads config.
- If several Pi instances run at once, use different `listen.port` values.
