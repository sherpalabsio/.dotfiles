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
bindkey '[113;9u' '__edit_config'

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
          --cycle
  )

  if [ -n "$selected_folder" ]; then
    __recently_used::used "edit_config" "$selected_folder"
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
bindkey "^[[112;9u" __edit_project # Cmd+p

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
alias cdps='cd ~/projects/local_sherpa'                     # cd project sherpa
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
bindkey "^[[111;9u" __cd_project # Cmd+o

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
bindkey "^[[111;10u" __cd_and_edit_project # Shift+Cmd+o

cdpn() {
  local selected
  selected=$(__select_project ~/projects-not-mine)

  if [[ -n "$selected" ]]; then
    cd "$selected"
  fi
}

# =================================== UTILS ====================================

setopt null_glob

__select_project() {
  local -r PROJECTS_DIR=${1:-~/projects}
  local eligible_projects=(
    $(
      __select_project__list_project_paths "$PROJECTS_DIR" |
        sed "s|^$PROJECTS_DIR/||"
    )
  )

  eligible_projects=($(__recently_used::merge "select_project" "${eligible_projects[@]}"))

  local -r selected=$(
    printf "%s\n" "${eligible_projects[@]}" |
      fzf --layout=reverse \
          --border \
          --info=inline \
          --margin=19%,11% \
          --padding=1 \
          --cycle
  )

  [ -z "$selected" ] && return

  __recently_used::used "select_project" "$selected"
  echo "$PROJECTS_DIR/$selected"
}

__select_project__list_project_paths() {
  local -r current_dir=$1

  # Don't print the starting directory
  if [[ $current_dir:h != $HOME ]]; then
    echo $current_dir
  fi

  __select_project__list_project_paths__should_we_stop "$current_dir" && return

  for subdir in "$current_dir"/*(/); do
    # Skip unwanted directories
    [[ ${subdir:t} = Z* ]] && continue
    [[ ${subdir:t} = *_assets ]] && continue

    __select_project__list_project_paths "$subdir"
  done
}

__select_project__list_project_paths__should_we_stop() {
  local -r current_dir=$1

  # Directories and files indicating we are in a project root
  local -r PROJECT_ROOT_INDICATORS=(
    "node_modules"
    "vendor"
    "_build"
    "bin"
    "spec"

    "README.md"
    "Gemfile"
    ".project"
    "mix.lock"
    "manifest.json"
    "package.json"
  )

  local project_root_indicator

  for project_root_indicator in $PROJECT_ROOT_INDICATORS; do
    [[ -e "$current_dir/$project_root_indicator" ]] && return 0
  done

  return 1
}
