---
tags:
  - openssl
  - certificates
variables:
  cert:
    command: rg --files -g '*.crt' -g '*.pem'
  p12:
    command: rg --files -g '*.p12' -g '*.pfx'
---

# Cert Snippets

## Inspect cert

```
openssl x509 -in <@cert> -noout -text
```

## Inspect p12 cert

```
openssl pkcs12 -in <@p12> -nokeys -info
```

## Extract cert from p12

```
openssl pkcs12 -in <@p12> -clcerts -nokeys -out <@out_crt>
```

## Extract key from p12

```
openssl pkcs12 -in <@p12> -nocerts -nodes -out <@out_key>
```

## Extract cert from p12 (legacy)

```
openssl pkcs12 -legacy -in <@p12> -clcerts -nokeys -out <@out_crt>
```

## Extract key from p12 (legacy)

```
openssl pkcs12 -legacy -in <@p12> -nocerts -nodes -out <@out_key>
```

## Validate cert

```
openssl x509 -in <@cert> -text -noout
```

## Validate p12

```
openssl pkcs12 -in <@p12> -info -noout
```

## Validate p12 (legacy)

```
openssl pkcs12 -legacy -in <@p12> -info -noout
```

## Create RSA key

```
openssl genrsa -out <@out_key> <@bits:echo "4096\n2048">
```
