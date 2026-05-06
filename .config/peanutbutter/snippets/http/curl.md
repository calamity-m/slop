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
---

# Curl Snippets

## curl with password protected p12

```
curl --cert-type P12 --cert '<@p12>:<@password>' '<@url>'
```

## curl with pem cert no password

```
curl --cert '<@cert>' --key '<@key>' '<@url>'
```

## curl with basic auth

```
curl --user '<@username>:<@password>' '<@url>'
```

## curl with json body

```
curl -X <@method:echo "POST\nPUT\nPATCH"> \
  -H 'Content-Type: application/json' \
  --data-binary @- \
  '<@url>' <<'JSON'
<@json_body>
JSON
```

## curl with form url encoded

```
curl -X <@method:echo "POST\nPUT\nPATCH"> \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d '<@field>=<@value>' \
  '<@url>'
```
