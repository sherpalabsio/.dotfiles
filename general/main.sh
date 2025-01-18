# Edit config (.dotfiles)
# It offers a list of folders in the dotfiles directory sorted by most recently
# opened. The user can select a folder to open in VS Code along with its content
# sorted by modification time.
ec() {
  local -r history_file="${DOTFILES_PATH}/tmp/.ec_history"
  local history_folders=""

  # Read history file if it exists
  if [[ -f "${history_file}" ]]; then
    history_folders=$(cat "${history_file}")
  fi

  local eligible_folders=$(
    find "${DOTFILES_PATH}" -maxdepth 1 -type d \
         ! -name "lib" \
         ! -name "tmp" \
         ! -name "local" \
         ! -name ".*" \
         ! -name "_*" \
         | awk -F/ '{print $NF}' \
         | grep -v "^${DOTFILES_PATH##*/}$"
  )

  # Start with existing history folders that still exist
  local sorted_folders=""
  while IFS= read -r folder; do
    if [[ -n "${folder}" ]] && echo "${eligible_folders}" | grep -q "^${folder}$"; then
      sorted_folders="${sorted_folders}${folder}\n"
    fi
  done <<< "${history_folders}"

  # Add any folders that aren't already in sorted_folders
  while IFS= read -r folder; do
    if [[ -n "${folder}" ]] && ! echo -e "${sorted_folders}" | grep -q "^${folder}$"; then
      sorted_folders="${sorted_folders}${folder}\n"
    fi
  done <<< "${eligible_folders}"

  # Select a folder using fzf
  local -r selected_folder=$(
    echo -e "${sorted_folders}" \
    | grep -v '^$' \
    | fzf --height 90% \
          --layout=reverse \
          --cycle
  )

  # Skip if no folder was selected
  [ -z "${selected_folder}" ] && return 1

  # Update history by moving selected folder to top
  # First add the selected folder, then add all other folders except the selected one
  echo "${selected_folder}" > "${history_file}"
  echo -e "${sorted_folders}" | grep -v "^${selected_folder}$" | grep -v '^$' >> "${history_file}"

  # Open the selected folder in VS Code along with its content
  # split by regular and hidden files and sort by modification time
  local -r folder_path="${DOTFILES_PATH}/${selected_folder}"
  local -r regular_files=$(find "${folder_path}" -maxdepth 1 -type f ! -name ".*" -exec ls -t {} + )
  local -r hidden_files=$(find "${folder_path}" -maxdepth 1 -type f -name ".*" -exec ls -t {} + )

  echo "$regular_files\n$hidden_files" |
    xargs code --new-window -n "${DOTFILES_PATH}"
}

alias eca='code ~/.dotfiles'       # Edit config all
alias ecl='code ~/.dotfiles/local' # Edit config local
alias eh='code $HISTFILE'          # Edit history
alias ehr='code ~/.irb_history'    # Edit history Rails

alias e='code .' # Edit current directory
alias o='open .' # Open current directory in Finder
alias http_server='python -m SimpleHTTPServer 8000'

# Reload the shell (i.e. invoke as a login shell)
alias rel="exec $SHELL -l"

# Remove directory
alias rmd="rm -rf"

alias cdw='cd ~/project-silverfin/web' # cd work
alias cd_blog='cd ~/projects/blog'
alias cd_blog_template='cd ~/projects/blog/template'
alias cd_blog_content='cd ~/projects/blog/content'

alias cdc='cd ~/.dotfiles'                                  # cd config
alias cdcl='cd ~/.dotfiles/local'                           # cd config local
alias cdp='cd ~/projects'                                   # Projects I'm currently working on
alias cdps='cd ~/projects/local_sherpa'                     # Sherpa
alias cdpm='cd ~/projects-mine'                             # Projects I'm not actively working on
alias cdpn='cd ~/projects-not-mine'                         # Gems etc
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
