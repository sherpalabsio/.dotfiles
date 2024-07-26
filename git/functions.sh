# Git rebase interactive N
# Rebase the last N commits interactively
# $ grbin 11 # Rebase the last 11 commits
grbin() {
  grbi "HEAD~$1"
}

# Git diff remote
# This filters out the changes that other contributors have made that
# I don't care about! Which comes handy after a hairy rebase.
gdr() {
  local current_branch=$(git_current_branch)
  git diff origin/$current_branch $current_branch -- $(git diff master $current_branch --name-only)
}

# Git bisect start - Start a bisect session
#
# Usage:
#   gbs_start [target_commit]
#
# Arguments:
#   target_commit - The left boundary of the bisect session. If not provided,
#                   a commit is selected interactively.
gbs_start() {
  if [ -n "$1" ]; then
    local -r target_commit="$1"
  else
    local -r target_commit=$(git log -n 100 --oneline | fzf | awk '{print $1}')
  fi

  git bisect start
  git bisect old "$target_commit"
  git bisect new
}
