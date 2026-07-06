---
tags:
  - kubernetes
  - kubectl
---

# Kubernetes

## Decode a Kubernetes secret value

The kind of multi-step lookup peanutbutter is built for, using **dependent
variables** (`<#name>`). Each picker narrows the next, and both commands run
against the current `kubectl` context namespace:

- `<@secret>` is picked from a live `kubectl get secret` list.
- `<@key>` lists only the data keys of the chosen secret, because its command
  references `<#secret>`.

Default `<#name>` substitution shell-single-quotes the upstream value, so
names with unusual characters are safe.

```bash
kubectl get secret \
  <@secret:kubectl get secret --no-headers -o custom-columns=NAME:.metadata.name> \
  -o jsonpath='{.data.<@key:kubectl get secret <#secret> -o go-template='{{range $k, $_ := .data}}{{$k}}{{"\n"}}{{end}}'>}' \
  | base64 -d \
  | tee <@output:?<#secret:raw>.<#key:raw>.out>
echo
```
