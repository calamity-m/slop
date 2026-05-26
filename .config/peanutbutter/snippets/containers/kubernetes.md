---
tags:
  - kubernetes
  - kubectl
---

# Kubernetes

## Decode a Kubernetes secret value

The kind of multi-step lookup peanutbutter is built for, using **dependent
variables** (`<#name>`). Each picker narrows the next:

- `<@namespace>` is picked from a live `kubectl get ns` list.
- `<@secret>` lists only the secrets in the chosen namespace, because its
  command references `<#namespace>`.
- `<@key>` lists only the data keys of the chosen secret, because its command
  references both `<#namespace>` and `<#secret>`.

Default `<#name>` substitution shell-single-quotes the upstream value, so
names with unusual characters are safe.

```bash
kubectl get secret \
  -n <@namespace:kubectl get ns --no-headers -o custom-columns=NAME:.metadata.name> \
  <@secret:kubectl get secret -n <#namespace> --no-headers -o custom-columns=NAME:.metadata.name> \
  -o jsonpath='{.data.<@key:kubectl get secret -n <#namespace> <#secret> -o go-template='{{range $k, $_ := .data}}{{$k}}{{"\n"}}{{end}}'>}' \
  | base64 -d \
  | tee <@output:?<#namespace:raw>.<#secret:raw>.<#key:raw>.out>
echo
```
