_fzf_complete_kubectl() {
  local ARGS="$COMP_LINE"

  if [[ $ARGS == 'kubectl config use-context'* || $ARGS == 'kubectl config delete-context'* ]]; then
    _fzf_complete --reverse --height=40% -- "$@" < <(
      kubectl config get-contexts -o name
    )
  elif [[ $ARGS == 'kubectl logs'* || $ARGS == 'kubectl exec'* || $ARGS == 'kubectl attach'* || $ARGS == 'kubectl port-forward'* ]]; then
    _fzf_complete --multi --header-lines=1 -- "$@" < <(
      kubectl get pods
    )
  elif [[ $ARGS == 'kubectl describe pod'* || $ARGS == 'kubectl delete pod'* ]]; then
    _fzf_complete --multi --header-lines=1 -- "$@" < <(
      kubectl get pods
    )
  elif [[ $ARGS == 'kubectl describe deployment'* || $ARGS == 'kubectl delete deployment'* || $ARGS == 'kubectl rollout'* ]]; then
    _fzf_complete --multi --header-lines=1 -- "$@" < <(
      kubectl get deployments
    )
  elif [[ $ARGS == 'kubectl describe service'* || $ARGS == 'kubectl delete service'* ]]; then
    _fzf_complete --multi --header-lines=1 -- "$@" < <(
      kubectl get services
    )
  elif [[ $ARGS == 'kubectl describe namespace'* || $ARGS == 'kubectl delete namespace'* ]]; then
    _fzf_complete --reverse --header-lines=1 -- "$@" < <(
      kubectl get namespaces
    )
  fi
}

_fzf_complete_kubectl_post() {
  awk '{print $1}'
}

complete -F _fzf_complete_kubectl -o default -o bashdefault kubectl
