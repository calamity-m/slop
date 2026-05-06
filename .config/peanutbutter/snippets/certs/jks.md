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

```
keytool -list -v -keystore <@jks>
```

## Inspect single alias

```
keytool -list -v -keystore <@jks> -alias <@alias>
```

## Import cert into keystore

```
keytool -importcert -file <@cert> -keystore <@jks> -alias <@alias>
```

## Convert p12 to jks

```
keytool -importkeystore -srckeystore <@p12> -srcstoretype PKCS12 -destkeystore <@out_jks> -deststoretype JKS
```

## Convert jks to p12

```
keytool -importkeystore -srckeystore <@jks> -srcstoretype JKS -destkeystore <@out_p12> -deststoretype PKCS12
```

## Delete alias from keystore

```
keytool -delete -alias <@alias> -keystore <@jks>
```
