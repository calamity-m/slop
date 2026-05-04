---
tags:
  - keytool
  - certificates
  - jks
---

# JKS Snippets

## Inspect keystore

```
keytool -list -v -keystore <@jks:rg . --files>
```

## Inspect single alias

```
keytool -list -v -keystore <@jks:rg . --files> -alias <@alias>
```

## Import cert into keystore

```
keytool -importcert -file <@crt:rg . --files> -keystore <@jks:rg . --files> -alias <@alias>
```

## Convert p12 to jks

```
keytool -importkeystore -srckeystore <@p12:rg . --files> -srcstoretype PKCS12 -destkeystore <@out_jks> -deststoretype JKS
```

## Convert jks to p12

```
keytool -importkeystore -srckeystore <@jks:rg . --files> -srcstoretype JKS -destkeystore <@out_p12> -deststoretype PKCS12
```

## Delete alias from keystore

```
keytool -delete -alias <@alias> -keystore <@jks:rg . --files>
```
