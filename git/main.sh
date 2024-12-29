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

# Rebase interactively the last n commits
alias grbi2='grbi HEAD~2 --autostash'
alias grbi3='grbi HEAD~3 --autostash'
alias grbi4='grbi HEAD~4 --autostash'
alias grbi5='grbi HEAD~5 --autostash'
alias grbi6='grbi HEAD~6 --autostash'
alias grbi7='grbi HEAD~7 --autostash'
alias grbi8='grbi HEAD~8 --autostash'
alias grbi9='grbi HEAD~9 --autostash'

# Rebase interactive all - Rebase all commits of the current feature branch interactively
grbia() {
  # If the current branch is the main branch, then return
  if [ "$(git_current_branch)" = "$(git_main_branch)" ]; then
    echo "You are on the main branch"
    return 1
  fi

  local -r commit_count=$(git rev-list --count HEAD ^$(git_main_branch))
  git rebase -i HEAD~$commit_count --autostash
}


# Rebase master
alias grbm='git rebase $(git_main_branch) --autostash'

# Squash fixup commits
alias grb_fixup='git rebase -i --autosquash $(git_main_branch)'

# Rebase continue all - Continue the rebase without editing the commit message
alias grbca='git add --all && GIT_EDITOR=true git rebase --continue'

alias git_clean_branches='git_clean_not_my_branches ; git_clean_merged_branches'
alias git_clean_not_my_branches='git branch --format "%(refname:short)" | grep -v "peter-" | grep -v "$(git_main_branch)" | xargs -r git branch -D'
alias git_clean_merged_branches="gfa && git branch --format '%(refname:short) %(upstream:track)' | awk '\$2 == \"[gone]\" { print \$1 }' | xargs -r git branch -D"
alias git_clean='gfa && git_clean_branches'

# Update - Sync changes from the remote master to the current branch
alias gupd='gplm && git_clean_merged_branches && grbm'
# Update remote - Sync changes from the remote master to the current branch and push the changes
alias gupdr='gupd && gpf'

# Commit
#
# Stages all the changes then commits them with the provided message.
# (no quotes are needed for the message)
# If no message is provided, it opens the default editor to write one.
# Usage:
#   gc <message> - Commit the changes with the provided message
unalias gc
gc() {
  git add --all

  # Is commit message is provided?
  if [ -n "$1" ]; then
    git commit -m "$*"
  else
    git commit
  fi
}

# Fixup commit
alias gc_fixup="git log -n 50 --pretty=format:'%h %s' --no-merges | fzf | awk '{ print \$1 }' | xargs -o git commit --fixup"
# Amend - Amend all changes to the last commit
alias gam='git add . && git commit --amend --no-edit'

# Log
alias gl='git log --oneline --graph'
# Log all
alias gla='git log --oneline --graph --all --decorate'
# Remotes - List all remotes
alias gr='git remote -v'
alias gs='git status'
alias gpf='git push -f'
alias gpl='git pull'
# Pull rebase
alias gplr='git pull --rebase origin $(git_current_branch)'
# Pull force - Overwrite the local branch with its remote counterpart
alias gplf='git reset origin/$(git_current_branch) --hard'
# Pull master - Update the local main branch without switching branches
alias gplm='git fetch origin $(git_main_branch):$(git_main_branch) --prune'
# Discard all changes
alias nah='git reset --hard && git clean -df'
# Undo - Removes the last commit while keeping its changes
alias gu="git reset --soft 'HEAD^'"

# GitX: Open repository in SourceTree (don't ask why I associate GitX with SourceTree)
alias gx='open -a SourceTree $(git rev-parse --show-toplevel || echo .)'
 # GitX config
alias gxc='open -a SourceTree ~/.dotfiles'
 # GitX config local
alias gxcl='open -a SourceTree ~/.dotfiles/local'
alias gxl='gxcl'

# Push config
alias gpc='git -C ~/.dotfiles push'
# Push config local
alias gpcl='git -C ~/.dotfiles/local push'

# Bisect start
alias gbss="gbs_start"
# Bisect abort
alias gbsa="git bisect reset"
# Bisect good
alias gbsg="git bisect old"
# Bisect bad
alias gbsb="git bisect new"

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

# Diff remote
#
# Compare the current branch with its remote counterpart after fixing conflicts.
# This filters out files that I didn't, but others changed.
gdr() {
  local current_branch=$(git_current_branch)
  git diff origin/$current_branch $current_branch -- $(git diff $git_main_branch $current_branch --name-only)
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

# Checkout back
alias gcb="git checkout -"

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

# Rename the current branch locally and remotely
# Usage:
#   gb_rename <new_branch>
gb_rename() {
  local -r current_branch=$(git_current_branch)
  local -r new_branch=$1

  git branch -m $new_branch
  git push origin :$current_branch $new_branch
  git push origin -u $new_branch
}
