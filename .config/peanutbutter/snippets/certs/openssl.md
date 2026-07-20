---
tags:
  - openssl
  - certificates
variables:
  cert:
    command: rg --files -g '*.crt' -g '*.pem'
  p12:
    command: rg --files -g '*.p12' -g '*.pfx'
  out_crt:
    default: client.crt
  out_key:
    default: client.key
---

# Cert Snippets

## Inspect cert

```bash
openssl x509 -in <@cert> -noout -text
```

## Inspect p12 cert

```bash
openssl pkcs12 -in <@p12> -nokeys -info
```

## Extract cert from p12

```bash
openssl pkcs12 -in <@p12> -clcerts -nokeys -out <@out_crt>
```

## Extract key from p12

```bash
openssl pkcs12 -in <@p12> -nocerts -nodes -out <@out_key>
```

## Extract cert from p12 (legacy)

```bash
openssl pkcs12 -legacy -in <@p12> -clcerts -nokeys -out <@out_crt>
```

## Extract key from p12 (legacy)

```bash
openssl pkcs12 -legacy -in <@p12> -nocerts -nodes -out <@out_key>
```

## Validate cert

```bash
openssl x509 -in <@cert> -text -noout
```

## Validate p12

```bash
openssl pkcs12 -in <@p12> -info -noout
```

## Validate p12 (legacy)

```bash
openssl pkcs12 -legacy -in <@p12> -info -noout
```

## Change passphrase on p12

```bash
openssl pkcs12 -in <@p12> -nodes | openssl pkcs12 -export -out <@out_p12>
```

## Create RSA key

```bash
openssl genrsa -out <@out_key> <@bits:echo "4096\n2048">
```
