alias ec='code ~/.dotfiles' # Edit config
alias eh='code $_history_file' # Edit history
alias erh='code ~/.irb_history' # Edit Rails history
alias ehr='code ~/.irb_history' # Edit history Rails

alias c='code .'
alias o='open .' # Open current directory in finder
alias http_server='python -m SimpleHTTPServer 8000'

# Reload the shell (i.e. invoke as a login shell)
alias rel="exec $SHELL -l"

# Remove directory
alias rmd="rm -rf"

alias cdw='cd ~/project-silverfin/web' # cd work
alias cd_blog='cd ~/projects/blog'
alias cd_blog_template='cd ~/projects/blog/template'
alias cd_blog_content='cd ~/projects/blog/content'

alias cdc='cd ~/.dotfiles' # cd config
alias cdcl='cd ~/.dotfiles/local' # cd config local
alias cdp='cd ~/projects' # Projects I'm currently working on
alias cdp1='cd ~/projects/local_sherpa' # Current project I'm currently working on
alias cdp2='cd ~/projects/vs_code_plugins/rails-generate' # Current project I'm currently working on
alias cdpm='cd ~/projects-mine' # Projects I'm not actively working on
alias cdpn='cd ~/projects-not-mine' # Gems etc
alias cdr='cd "$(git rev-parse --show-toplevel || echo .)"' # cd root

alias cdtu='cd ~/tutorials'
alias cdtj='cd ~/tutorials/js'
alias cdtr='cd ~/tutorials/ruby'

alias cdt='cd ~/tmp'
alias cdtmp='cd ~/tmp'

alias tm='tmux'
alias tma='tmux a'


alias backup_vlc_config='mv -v ~/Library/Preferences/org.videolan.vlc/vlcrc ~/.dotfiles/others/vlc/vlcrc && ln -s ~/.dotfiles/others/vlc/vlcrc ~/Library/Preferences/org.videolan.vlc/vlcrc'
alias apply_vlc_config_from_dotfiles='rmd ~/Library/Preferences/org.videolan.vlc/vlcrc ; ln -s ~/.dotfiles/others/vlc/vlcrc ~/Library/Preferences/org.videolan.vlc/vlcrc'

alias k='kubectl'
alias k_logs='kubectl logs -f'
alias k_get='kubectl get'
alias k_pods='kubectl get pods'

alias ng='ngrok http 3000' # opens an Ngrok tunnel to the local dev env

alias s='sherpa'
alias se='sherpa edit'
alias st='sherpa trust'

alias upgrade_sherpa='git -C $DOTFILES/lib/local_sherpa pull'
