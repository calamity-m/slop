# Cert Snippets

## Extract cert from p12

```
openssl pkcs12 -in <@p12:rg . --files> -clcerts -nokeys -out <@out_crt>
```

## Extract key from p12

```
openssl pkcs12 -in <@p12:rg . --files> -nocerts -nodes -out <@out_key>
```

## Extract cert from p12 (legacy)

```
openssl pkcs12 -legacy -in <@p12:rg . --files> -clcerts -nokeys -out <@out_crt>
```

## Extract key from p12 (legacy)

```
openssl pkcs12 -legacy -in <@p12:rg . --files> -nocerts -nodes -out <@out_key>
```

## Validate cert

```
openssl x509 -in <@crt:rg . --files> -text -noout
```

## Validate p12

```
openssl pkcs12 -in <@p12:rg . --files> -info -noout
```

## Validate p12 (legacy)

```
openssl pkcs12 -legacy -in <@p12:rg . --files> -info -noout
```

## Create RSA key

```
openssl genrsa -out <@out_key> <@bits:echo "4096\n2048">
```
