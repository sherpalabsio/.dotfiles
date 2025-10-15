alias k='kubectl'
alias klogs='kubectl logs -f'
alias pods='kubectl get pods'

kube_change_context() {
  local ctx
  ctx=$(
    kubectl config get-contexts -o name | \
      fzf --layout=reverse \
          --border \
          --info=inline \
          --margin=19%,11% \
          --padding=1 \
          --cycle \
          --border-label=" Change K8s Context "
    )

  [[ -n "$ctx" ]] && kubectl config use-context "$ctx"
}

alias kcont="kubectl config current-context"
