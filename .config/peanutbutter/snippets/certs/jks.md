---
tags:
  - keytool
  - certificates
  - jks
variables:
  cert:
    command: rg --files -g '*.crt' -g '*.pem'
  jks:
    command: rg --files -g '*.jks'
  p12:
    command: rg --files -g '*.p12' -g '*.pfx'
---

# JKS Snippets

## Inspect keystore

```bash
keytool -list -v -keystore <@jks>
```

## Inspect single alias

```bash
keytool -list -v -keystore <@jks> -alias <@alias>
```

## Import cert into keystore

```bash
keytool -importcert -file <@cert> -keystore <@jks> -alias <@alias>
```

## Convert p12 to jks

```bash
keytool -importkeystore -srckeystore <@p12> -srcstoretype PKCS12 -destkeystore <@out_jks> -deststoretype JKS
```

## Convert jks to p12

```bash
keytool -importkeystore -srckeystore <@jks> -srcstoretype JKS -destkeystore <@out_p12> -deststoretype PKCS12
```

## Delete alias from keystore

```bash
keytool -delete -alias <@alias> -keystore <@jks>
```
