# grbi - Git rebase interactive
#
# Usage:
#   grbi <number> - Starts an interactive rebase for the last <n> commits
#   grbi <args>   - Calls 'git rebase -i' with the provided arguments
#
# If the first argument is a number, it rebases interactively the last <n> commits.
# Otherwise, it passes all arguments to 'git rebase -i' for standard behavior.

unalias grbi
grbi() {
  if [[ $1 =~ ^[0-9]+$ ]]; then
    grbi "HEAD~$1"
  else
    git rebase -i $@
  fi
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

# Git checkout
unalias gco
gco() {
  if [ -z "$1" ]; then
    # List all the branches and let the user select one if no arguments are provided
    git branch | grep -v "^\*" | fzf --height=20% --reverse --info=inline | xargs git checkout
  else
    # Otherwise, fallback to the default behavior
    git checkout $@
  fi
}

# Git cherry-pick
unalias gcp
gcp() {
  if [ -z "$1" ]; then
    # List all the branches and let the user select one if no arguments are provided
    git log -n 200 --oneline --graph --all | \
      fzf --height=20% --reverse --info=inline | \
      grep -o "[a-f0-9]\{7\}" | sed -n "1p" | \
      xargs git cherry-pick
  else
    # Otherwise, fallback to the default behavior
    git cherry-pick $@
  fi
}
