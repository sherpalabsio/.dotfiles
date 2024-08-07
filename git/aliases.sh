# Rebase interactively the last n commits
alias grbi2='grbi HEAD~2 --autostash'
alias grbi3='grbi HEAD~3 --autostash'
alias grbi4='grbi HEAD~4 --autostash'
alias grbi5='grbi HEAD~5 --autostash'
alias grbi6='grbi HEAD~6 --autostash'
alias grbi7='grbi HEAD~7 --autostash'
alias grbi8='grbi HEAD~8 --autostash'
alias grbi9='grbi HEAD~9 --autostash'

# Rebase master
alias grbm='git rebase $(git_main_branch) --autostash'

# Squash fixup commits
alias grb_fixup='git rebase -i --autosquash $(git_main_branch)'

# Rebase interactive all - Rebase all commits of the current feature branch interactively
alias grbia='git rebase -i $(git_main_branch) --autostash'
# Rebase continue all - Continue the rebase without editing the commit message
alias grbca='git add --all && GIT_EDITOR=true git rebase --continue'

alias git_clean_branches='git_clean_not_my_branches && git_clean_merged_branches'
alias git_clean_not_my_branches='git branch --format "%(refname:short)" | grep -v "peter-" | grep -v "$(git_main_branch)" | xargs -r git branch -D'
alias git_clean_merged_branches="git branch --format '%(refname:short) %(upstream:track)' | awk '\$2 == \"[gone]\" { print \$1 }' | xargs -r git branch -D"

# Update - Sync changes from the remote master to the current branch
alias gupd='gplm && grbm && git_clean_merged_branches && gfa'
# Update remote - Sync changes from the remote master to the current branch and push the changes
alias gupdr='gupd && gpf'

# Commit for lazy devs like myself
alias gc='git add . && git commit -m'
# Fixup commit
alias gc_fixup="git log -n 50 --pretty=format:'%h %s' --no-merges | fzf | awk \"{ print \$1 }\" | xargs -o git commit --fixup"
# Ammend - Ammend all changes to the last commit
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

# Checkout back
alias gcb="git checkout -"

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
