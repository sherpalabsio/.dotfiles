alias o='open .' # Open current directory in Finder
alias http_server='python -m http.server 8000'

# Reload the shell (i.e. invoke as a login shell)
alias rel="exec $SHELL -l"

# Remove directory
alias rmd="rm -rf"

alias tm='tmux'
alias tma='tmux a'

alias vlc_backup_config='mv -v ~/Library/Preferences/org.videolan.vlc/vlcrc ~/.dotfiles/others/vlc/vlcrc && ln -s ~/.dotfiles/others/vlc/vlcrc ~/Library/Preferences/org.videolan.vlc/vlcrc'
alias vlc_restore_config='rmd ~/Library/Preferences/org.videolan.vlc/vlcrc ; ln -s ~/.dotfiles/others/vlc/vlcrc ~/Library/Preferences/org.videolan.vlc/vlcrc'

alias k='kubectl'
alias k_logs='kubectl logs -f'
alias k_get='kubectl get'
alias k_pods='kubectl get pods'

alias ng='ngrok http 3000' # opens an Ngrok tunnel to the local dev env

alias s='sherpa'
alias se='sherpa edit'
alias st='sherpa trust'

alias sherpa_upgrade_='git -C $DOTFILES_PATH/lib/local_sherpa pull'
alias sherpa_upgrade_f='git -C $DOTFILES_PATH/lib/local_sherpa reset origin/main --hard'

alias screenshot_enable_shadow='defaults write com.apple.screencapture disable-shadow -bool false && killall SystemUIServer'
alias screenshot_disable_shadow='defaults write com.apple.screencapture disable-shadow -bool true && killall SystemUIServer'

alias llm='ollama run llama3.1'

# Print the last exit code
alias '?'='echo $?'
alias w='which'

# Print the value of a variable
p() {
  local -r var_name=$1
  echo ${(P)var_name}
}

repeat_until_fails() {
  while true; do
    $@
    [[ $? -ne 0 ]] && break # exit if any of the tests failed
  done

  echo "FAILED: $@"
}

is_url_open_in_browser() {
  local -r url=$1

  local -r apple_script="
    tell application \"Google Chrome\"
      repeat with current_tab in tabs of front window
        if URL of current_tab contains \"$url\" then
          return true
        end if
      end repeat

      return false
    end tell"

  local -r result=$(osascript -e "$apple_script")

  if [ "$result" = "true" ]; then
    return 0
  else
    return 1
  fi
}

alias generate_invoice='~/.dotfiles/local/silverfin/invoice/generate'

alias use_sherpa_dev_version="mkdir -p ~/.config/local_sherpa && touch ~/.config/local_sherpa/use_dev_version && rel"
alias use_sherpa_prod_version="rm -f ~/.config/local_sherpa/use_dev_version && rel"
