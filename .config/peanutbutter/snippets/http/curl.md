---
tags:
  - curl
  - http
variables:
  cert:
    command: rg --files -g '*.crt' -g '*.pem'
  key:
    command: rg --files -g '*.pem' -g '*.key'
  p12:
    command: rg --files -g '*.p12' -g '*.pfx'
  url:
    default: https://
  output_file:
    default: output.txt
---

# Curl Snippets

## curl with password protected p12

```bash
curl --cert-type P12 --cert '<@p12>:<@password>' '<@url>'
```

## curl with pem cert no password

```bash
curl --cert '<@cert>' --key '<@key>' '<@url>'
```

## curl with basic auth

```bash
curl --user '<@username>:<@password>' '<@url>'
```

## curl output to file

```bash
curl --output '<@output_file>' '<@url>'
```

## curl with json body

```bash
curl -X <@method:echo "POST\nPUT\nPATCH"> \
  -H 'Content-Type: application/json' \
  --data-binary @- \
  '<@url>' <<'JSON'
<@json_body>
JSON
```

## curl with form url encoded

```bash
curl -X <@method:echo "POST\nPUT\nPATCH"> \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d '<@field>=<@value>' \
  '<@url>'
```

## curl against sse endpoint to test

```bash
curl -N -H "Accept: text/event-stream" <@sse_endpoint:?https://stream.wikimedia.org/v2/stream/recentchange>
```

## curl test http version

Output will be the http version used, i.e. 2 or 1.1.

```bash
curl -sI @<url> -o/dev/null -w '%{http_version}\n'
```

## curl test http/2 support explicitly

**What to look for in the output:**

- If HTTP/2 is supported, the very first line of the response headers will explicitly state HTTP/2 200 (or another status code).
- If it is not supported, the server will negotiate a fallback, and you will see HTTP/1.1 200 OK instead.

```bash
curl -I --http2 <@url>
```

```

```
