---
tags:
  - kubernetes
  - kubectl
---

# Kubernetes

## Decode a Kubernetes secret value (current namespace)

```bash
kubectl get secret \
  <@secret:kubectl get secret --no-headers -o custom-columns=NAME:.metadata.name> \
  -o jsonpath='{.data.<@key:kubectl get secret <#secret> -o go-template='{{range $k, $_ := .data}}{{$k}}{{"\n"}}{{end}}'>}' \
  | base64 -d \
  | tee <@output:?<#secret:raw>.<#key:raw>.out>
echo
```
