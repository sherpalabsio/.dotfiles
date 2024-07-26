alias grbi2='grbi HEAD~2'
alias grbi3='grbi HEAD~3'
alias grbi4='grbi HEAD~4'
alias grbi5='grbi HEAD~5'
alias grbi6='grbi HEAD~6'
alias grbi7='grbi HEAD~7'
alias grbi8='grbi HEAD~8'
alias grbi9='grbi HEAD~9'

# Rebase to master iteratively
alias grbmi='grbi main'

# Squash fixup commits
alias grb_fixup='git rebase -i --autosquash $(git_main_branch)'

# Rebase all commits in the current branch iteratively
alias grbia='git rebase -i $(git_main_branch)'

# Update = sync changes from the remote master to the current branch
alias gupd='gplm && grbm && gfa'
# Update iteratively
alias gupdi='gplm && grbmi'
# Update remote = sync changes from the current branch to its remote counterpart
alias gupdr='gplm && grbm && gpf && gfa'

# Commit for lazy devs like myself
alias gc='git commit -m'
# Fixup commit | brew install fzf
alias gc_fixup="git log -n 50 --pretty=format:'%h %s' --no-merges | fzf | awk \"{ print \$1 }\" | xargs -o git commit --fixup"
# Ammend all changes to the last commit
alias gam='git add . && git commit --amend --no-edit'

alias gl='git log --oneline --graph --all --decorate'
# List the remotes
alias gr='git remote -v'
alias gs='git status'
alias gpf='git push -f'
alias gpl='git pull'
alias gplr='git pull --rebase origin $(git_current_branch)'
# Pull force = overwrite local branch with its remote counterpart
alias gplf='git reset origin/$(git_current_branch) --hard'
# Pull master = update the local main branch, without the need to switch to it
alias gplm='git fetch origin $(git_main_branch):$(git_main_branch)'
# Discard all changes
alias nah='git reset --hard && git clean -df'
# Undo = removes the last commit while keeping its changes
alias gu="git reset --soft 'HEAD^'"

# Checkout back to the previous branch
alias gchb="git checkout -"

# Diff origin
alias gdo="git diff @{upstream}"

# GitX: Open repository in SourceTree (don't ask why I associate GitX with SourceTree)
alias gx='open -a SourceTree $(git rev-parse --show-toplevel || echo .)'
alias gxc='open -a SourceTree ~/.dotfiles' # GitX config local
alias gxcl='open -a SourceTree ~/.dotfiles/local' # GitX config local
alias gxl='lazygit'

alias gpc='git -C ~/.dotfiles push' # Git push config
alias gpcl='git -C ~/.dotfiles/local push' # Git push config local

# Git bisect start
alias gbss="gbs_start"
# Git bisect abort
alias gbsa="git bisect reset"
# Git bisect good
alias gbsg="git bisect old"
# Git bisect bad
alias gbsb="git bisect new"
