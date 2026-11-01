# ==================================== EDIT ====================================
# Edit the current directory or a given path in VS Code
e() {
  if [[ -n "$1" ]]; then
    code "$1"
  else
    code .
  fi
}

alias ec='code ~/.dotfiles'        # Edit config
alias ecl='code ~/.dotfiles/local' # Edit config local
alias eh='code $HISTFILE'          # Edit history

# Edit config (.dotfiles)
# It offers a list of folders in the dotfiles directory sorted by most recently
# opened. The user can select a folder to open in VS Code along with its content
# sorted by modification time.
__edit_config() {
  if [[ -n "$1" ]]; then
    local -r selected_folder="$1"
  else
    local -r selected_folder="$(__ec__select_folder)"
  fi

  # Skip if no folder was selected
  [ -z "${selected_folder}" ] && return

  # Open the selected folder in VS Code along with its content
  # split by regular and hidden files and sort by modification time
  local -r folder_path="${DOTFILES_PATH}/${selected_folder}"
  local -r regular_files=$(find "${folder_path}" -maxdepth 1 -type f ! -name ".*" -exec ls -t {} +)
  local -r hidden_files=$(find "${folder_path}" -maxdepth 1 -type f -name ".*" ! -name ".DS_Store" -exec ls -t {} +)

  echo "$regular_files\n$hidden_files" |
    xargs code --new-window -n "$DOTFILES_PATH/$selected_folder"
}

zle -N __edit_config
bindkey '^[[44;8u' '__edit_config' # cmd + ,

__ec__select_folder() {
  local eligible_folders=($(
    find "${DOTFILES_PATH}" -maxdepth 1 -type d \
         ! -name "lib" \
         ! -name "tmp" \
         ! -name "local" \
         ! -name ".*" \
         ! -name "_*" |
           awk -F/ '{print $NF}' |
           grep -v "^${DOTFILES_PATH##*/}$"
  ))

  eligible_folders=($(__recently_used::merge "edit_config" "${eligible_folders[@]}"))

  # Select a folder using fzf
  local -r selected_folder=$(
    printf "%s\n" "${eligible_folders[@]}" |
      grep -v '^$' |
      fzf --layout=reverse \
          --border \
          --info=inline \
          --margin=19%,11% \
          --padding=1 \
          --cycle \
          --border-label=" Edit Config "
  )

  if [ -n "$selected_folder" ]; then
    __recently_used::add "edit_config" "$selected_folder"
  fi

  echo "${selected_folder}"
}

# ===================================== CD =====================================
alias cdc='cd ~/.dotfiles'                                  # cd config
alias cdcl='cd ~/.dotfiles/local'                           # cd config local
alias cdp='cd ~/projects'                                   # cd projects all
alias cdpm='cd ~/projects-mine'                             # cd projects mine
alias cdpn='cd ~/projects-not-mine'                         # cd projects not mine
alias cdny='cd ~/projects/nyomda/print_works'
alias cds='cd ~/projects/nyomda/data_service'

alias cdt='cd ~/tmp'
