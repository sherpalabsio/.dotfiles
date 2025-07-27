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
alias ehr='code ~/.irb_history'    # Edit history Ruby

alias ecge="__edit_config general" # Edit config Main/General
alias ecgi="__edit_config git"     # Edit config Git
alias ecd="__edit_config docker"   # Edit config Rails
alias ecr="__edit_config ruby"     # Edit config Ruby
alias ece="__edit_config elixir"   # Edit config Elixir
alias ecv="__edit_config vs_code"  # Edit config VS Code

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

__edit_project() {
  local selected
  selected=$(__select_project)

  if [[ -n "$selected" ]]; then
    code "$selected"
  fi
}

zle -N __edit_project
bindkey "^[[80;8u" __edit_project # cmd + p

# Edit project not mine
epn() {
  local selected
  selected=$(__select_project ~/projects-not-mine)

  if [[ -n "$selected" ]]; then
    code "$selected"
  fi
}

# ===================================== CD =====================================
alias cdc='cd ~/.dotfiles'                                  # cd config
alias cdcl='cd ~/.dotfiles/local'                           # cd config local
alias cdp='cd ~/projects'                                   # cd projects all
alias cdps='cd ~/projects/local_sherpa/local_sherpa'        # cd project sherpa
alias cdpm='cd ~/projects-mine'                             # cd projects mine
alias cdpna='cd ~/projects-not-mine'                        # cd projects not mine
alias cdr='cd "$(git rev-parse --show-toplevel || echo .)"' # cd root

alias cdtu='cd ~/tutorials'
alias cdtj='cd ~/tutorials/js'
alias cdtr='cd ~/tutorials/ruby'

alias cdt='cd ~/tmp'

__cd_project() {
  local selected
  selected=$(__select_project)

  if [[ -n "$selected" ]]; then
    zle accept-line
    cd "$selected"
  fi
}

zle -N __cd_project
bindkey "^[[79;8u" __cd_project # cmd + o

# Open the selected project in the current terminal session and in VS Code
__cd_and_edit_project() {
  local selected
  selected=$(__select_project)

  if [[ -n "$selected" ]]; then
    zle accept-line
    cd "$selected"
    code .
  fi
}

zle -N __cd_and_edit_project
bindkey "^[[79;9u" __cd_and_edit_project # shift + cmd + o

# =================================== Utils ====================================

__DOTFILES_BOOKMARK_FILE="$DOTFILES_PATH/tmp/project_bookmarks"

setopt null_glob

add_project_bookmark() {
  local -r current_path="$(pwd)"

  # Skip if already bookmarked
  if grep -Fq "$current_path|" "$__DOTFILES_BOOKMARK_FILE"; then
    return 0
  fi

  local name="$1"
  if [ -z "$name" ]; then
    name=$(
      echo "$current_path" |
        sed -e "s|^$HOME/projects/||" -e "s|^$HOME/projects-not-mine/||"
    )
  fi

  echo "$current_path|$name" >> "$__DOTFILES_BOOKMARK_FILE"
}

edit_project_bookmarks() {
  code "$__DOTFILES_BOOKMARK_FILE"
}

remove_project_bookmark() {
  local -r current_dir=$(pwd)
  sed -i '' "/^${current_dir//\//\\/}/d" "$__DOTFILES_BOOKMARK_FILE"
}

__select_project() {
  local -r selected_bookmark=$(
    cat "$__DOTFILES_BOOKMARK_FILE" |
      fzf --delimiter='\|' \
          --with-nth=2 \
          --layout=reverse \
          --border \
          --info=inline \
          --margin=19%,11% \
          --padding=1 \
          --cycle \
          --border-label=" Projects "
  )

  [ -z "$selected_bookmark" ] && return

  # Move the selected project to the top of the bookmarks file
  local -r temp_file=$(mktemp)
  grep -Fxv "$selected_bookmark" "$__DOTFILES_BOOKMARK_FILE" > "$temp_file"
  echo "$selected_bookmark" > "$__DOTFILES_BOOKMARK_FILE"
  cat "$temp_file" >> "$__DOTFILES_BOOKMARK_FILE"
  rm "$temp_file"

  echo "$selected_bookmark" | cut -d'|' -f1
}
