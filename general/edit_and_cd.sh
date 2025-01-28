# ==================================== EDIT ====================================
alias e='code .' # Edit current directory
alias eca='code ~/.dotfiles'       # Edit config all
alias ecl='code ~/.dotfiles/local' # Edit config local
alias eh='code $HISTFILE'          # Edit history
alias ehr='code ~/.irb_history'    # Edit history Ruby

alias ecg="ec git"      # Edit config Git
alias ecm="ecge"        # Edit config Main
alias ecr="ec ruby"     # Edit config Ruby
alias ecd="ec docker"   # Edit config Rails
alias ece="ec elixir"   # Edit config Elixir

# Edit config (.dotfiles)
# It offers a list of folders in the dotfiles directory sorted by most recently
# opened. The user can select a folder to open in VS Code along with its content
# sorted by modification time.
ec() {
  if [[ -n "$1" ]]; then
    local -r selected_folder="$1"
  else
    local -r selected_folder="$(__ec__select_folder)"
  fi

  # Skip if no folder was selected
  [ -z "${selected_folder}" ] && return 1

  # Update history by moving selected folder to top
  # First add the selected folder, then add all other folders except the selected one
  local -r history_file="${DOTFILES_PATH}/tmp/.ec_history"
  echo "${selected_folder}" > "${history_file}"
  echo -e "${sorted_folders}" | grep -v "^${selected_folder}$" | grep -v '^$' >> "${history_file}"

  # Open the selected folder in VS Code along with its content
  # split by regular and hidden files and sort by modification time
  local -r folder_path="${DOTFILES_PATH}/${selected_folder}"
  local -r regular_files=$(find "${folder_path}" -maxdepth 1 -type f ! -name ".*" -exec ls -t {} +)
  local -r hidden_files=$(find "${folder_path}" -maxdepth 1 -type f -name ".*" -exec ls -t {} +)

  echo "$regular_files\n$hidden_files" |
    xargs code --new-window -n "${DOTFILES_PATH}"
}

__ec__select_folder() {
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
         ! -name "_*" |
           awk -F/ '{print $NF}' |
           grep -v "^${DOTFILES_PATH##*/}$"
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
    echo -e "${sorted_folders}" |
      grep -v '^$' |
      fzf --height 90% \
          --layout=reverse \
          --cycle
  )

  echo "${selected_folder}"
}

# Edit project
ep() {
  local selected
  selected=$(__select_project)

  if [[ -n "$selected" ]]; then
    code "$selected"
  fi
}

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
alias cdpa='cd ~/projects'                                  # cd projects all
alias cdps='cd ~/projects/local_sherpa'                     # cd project sherpa
alias cdpm='cd ~/projects-mine'                             # cd projects mine
alias cdpna='cd ~/projects-not-mine'                        # cd projects not mine
alias cdr='cd "$(git rev-parse --show-toplevel || echo .)"' # cd root

alias cdtu='cd ~/tutorials'
alias cdtj='cd ~/tutorials/js'
alias cdtr='cd ~/tutorials/ruby'

alias cdt='cd ~/tmp'

cdp() {
  local selected
  selected=$(__select_project)

  if [[ -n "$selected" ]]; then
    cd "$selected"
  fi
}

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
  local selected

  selected=$(
    __list_project_paths "$PROJECTS_DIR" |
      sed "s|^$PROJECTS_DIR/||" |
      fzf --height 90% \
          --layout=reverse \
          --cycle
  )

  if [[ -z "$selected" ]]; then
    return 1
  fi

  echo "$PROJECTS_DIR/$selected"
}

__list_project_paths() {
  local -r current_dir=$1

  # Don't print the starting directory
  if [[ $current_dir:h != $HOME ]]; then
    echo $current_dir
  fi

  __list_project_paths__should_we_stop "$current_dir" && return

  for subdir in "$current_dir"/*(/); do
    # Skip unwanted directories
    [[ ${subdir:t} = Z* ]] && continue
    [[ ${subdir:t} = *_assets ]] && continue

    __list_project_paths "$subdir"
  done
}

__list_project_paths__should_we_stop() {
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
