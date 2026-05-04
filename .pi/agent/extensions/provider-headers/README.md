# Provider Headers Pi Extension

Adds configured HTTP headers to Pi model provider requests.

Create `~/.pi/agent/provider-headers.json`:

```json
{
  "openai": {
    "X-Team": "platform",
    "X-Request-Source": "pi"
  },
  "anthropic": {
    "X-Corp-Auth": "CORP_AUTH_TOKEN"
  }
}
```

Header values may be literals or environment variable names supported by Pi provider config.

To use a different config file:

```bash
PI_PROVIDER_HEADERS_CONFIG=/path/to/provider-headers.json pi
```

Run `/reload` after changing the extension or config.
