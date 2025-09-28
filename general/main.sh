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
alias k_pods='kubectl get pods'

alias ng='ngrok http 3000' # opens an Ngrok tunnel to the local dev env

alias s='sherpa'
alias se='sherpa edit'
alias st='sherpa trust'

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

free_up_port() {
  local -r port="$1"
  local -r pids=$(lsof -ti :$port -sTCP:LISTEN)

  # Skip if the port is not in use
  [ -z "$pids" ] && return

  print_in_yellow "Freeing up port $1" -n

  while IFS= read -r pid; do
    kill "$pid"
  done <<< "$pids"

  while lsof -ti :$1 -sTCP:LISTEN > /dev/null; do
    sleep 0.3
    echo -n "."
  done

  echo ""
}

alias generate_invoice='~/.dotfiles/local/silverfin/invoice/generate'

alias use_sherpa_dev_version="mkdir -p ~/.config/local_sherpa && touch ~/.config/local_sherpa/use_dev_version && rel"
alias use_sherpa_prod_version="rm -f ~/.config/local_sherpa/use_dev_version && rel"
