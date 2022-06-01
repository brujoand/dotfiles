#!/usr/bin/env bash

if type kubectl &>/dev/null; then
  alias k='kubectl' # Run kubectl
  source <(kubectl completion bash)
  complete -o default -F _alias_completion_wrapper k
  alias kg='kubectl get' # Run kubectl get
  complete -o default -F _alias_completion_wrapper kg
  alias kl='kubectl logs' # Run kubectl logs
  complete -o default -F _alias_completion_wrapper kl
  alias ke='kubectl exec -it'
  complete -o default -F _alias_completion_wrapper ke
  alias kgp='kubectl get pods' # Run kubectl get pods
  complete -o default -F _alias_completion_wrapper kgp
  alias kgs='kubectl get services' # Run kubecetl get services
  complete -o default -F _alias_completion_wrapper kgs
  alias kge='kubectl get events' # Run kubecetl get events
  complete -o default -F _alias_completion_wrapper kge

fi

function kcc() { # Switch between k8s contexts
  local context
  if [[ -z $1 ]]; then
    context=$(kubectl config get-contexts -o name | fzf)
  else
    context=$1
  fi

  if [[ -n $context ]]; then
    kubectl config use-context "$context"
  fi
}

function kcn() { # Switch between k8s namespaces
  local namespace
  if [[ -z $1 ]]; then
    namespace=$(kubectl get namespaces | cut -d ' ' -f 1 | fzf)
  else
    namespace=$1
  fi

  if [[ -n $namespace ]]; then
    kubectl config set-context --current --namespace="$namespace"
  fi
}



