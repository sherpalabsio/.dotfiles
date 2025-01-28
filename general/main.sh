alias o='open .' # Open current directory in Finder
alias http_server='python -m SimpleHTTPServer 8000'

# Reload the shell (i.e. invoke as a login shell)
alias rel="exec $SHELL -l"

# Remove directory
alias rmd="rm -rf"

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

alias upgrade_sherpa='git -C $DOTFILES_PATH/lib/local_sherpa pull'
alias upgrade_sherpa_f='git -C $DOTFILES_PATH/lib/local_sherpa reset origin/main --hard'

alias screenshot_enable_shadow='defaults write com.apple.screencapture disable-shadow -bool false && killall SystemUIServer'
alias screenshot_disable_shadow='defaults write com.apple.screencapture disable-shadow -bool true && killall SystemUIServer'

alias llm='ollama run llama3.1'

# Print the last exit code
alias '?'='echo $?'

# Print the value of a variable
p() {
  local -r var_name=$1
  echo ${(P)var_name}
}

# Find alias using fuzy search then execute the selected one
find_alias() {
  # Capture the selected alias using fzf and awk
  local selected_alias
  selected_alias=$(alias | fzf | awk -F'=' '{print $1}')

  # Execute the selected alias if there is one
  if [ -n "$selected_alias" ]; then
    echo "Executing: $selected_alias"
    eval "$selected_alias"
  fi
}

repeat_until_fails() {
  while true; do
    $@
    [[ $? -ne 0 ]] && break # exit if any of the tests failed
  done

  echo "FAILED: $@"
}

# ==============================================================================
# Screen Cast Environment

readonly _ORIGINAL_BACKGROUND_PATH=~/.dotfiles/local/original_background.txt
readonly _NEW_BACKGROUND_PATH=/Volumes/DriveD/Dropbox/YT\ Brand/sizing_bg.jpg

readonly _ORIGINAL_DOCK_SIZE_PATH=~/.dotfiles/local/original_dock_size.txt
readonly _DESIRED_DOCK_SIZE=71

screen_cast_env__activate() {
  # Change the background
  osascript -e 'tell application "System Events" to picture of every desktop' > $_ORIGINAL_BACKGROUND_PATH
  osascript -e 'tell application "System Events" to set picture of every desktop to "'"$_NEW_BACKGROUND_PATH"'"'
}

screen_cast_env__deactivate() {
  # Restore the background
  original_background=$(cat $_ORIGINAL_BACKGROUND_PATH)
  osascript -e 'tell application "System Events" to set picture of every desktop to "'"$original_background"'"'
}
