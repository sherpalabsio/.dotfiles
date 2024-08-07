# Rebase interactive
#
# Usage:
#   grbi <number> - Starts an interactive rebase for the last <n> commits
#   grbi <args>   - Calls 'git rebase -i' with the provided arguments
#
# If the first argument is a number, it rebases interactively the last <n> commits.
# Otherwise, it falls back to the original behavior.

unalias grbi
grbi() {
  if [[ $1 =~ ^[0-9]+$ ]]; then
    grbi "HEAD~$1"
  else
    git rebase -i $@
  fi
}

# Diff remote
#
# Compare the current branch with its remote counterpart after fixing conflicts.
# This filters out files that I didn't, but others changed.
gdr() {
  local current_branch=$(git_current_branch)
  git diff origin/$current_branch $current_branch -- $(git diff master $current_branch --name-only)
}

# Bisect start - Start a bisect session
#
# Usage:
#   gbs_start          - Start a bisect session with the commit selected interactively
#   gbs_start <commit> - Start a bisect session with the provided commit
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

# Checkout
#
# Usage:
#   gco          - List all the branches and let the user select one
#   gco <branch> - Checkout the provided branch
unalias gco
gco() {
  if [ -z "$1" ]; then
    # List all the branches and let the user select one if no arguments are provided
    git branch | grep -v "^\*" | fzf --height=20% --reverse --info=inline | xargs git checkout
  else
    # Otherwise, fallback to the original behavior
    git checkout $@
  fi
}

# Cherry-pick
#
# Usage:
#   gcp          - List all the branches and let the user select one
#   gcp <commit> - Cherry-pick the provided commit
unalias gcp
gcp() {
  if [ -z "$1" ]; then
    # List all the branches and let the user select one if no arguments are provided
    git log -n 200 --oneline --graph --all | \
      fzf --height=20% --reverse --info=inline | \
      grep -o "[a-f0-9]\{7\}" | sed -n "1p" | \
      xargs git cherry-pick
  else
    # Otherwise, fallback to the original behavior
    git cherry-pick $@
  fi
}
