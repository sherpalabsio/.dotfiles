# Open a command plate with all the aliases and functions I defined by myself
__select_my_command() {
  local commands selected_command

  commands=(
    $(__select_my_command__load_global_aliases)
    $(__select_my_command__load_local_aliases)
    $(__select_my_command__load_global_functions)
    $(__select_my_command__load_local_functions)
  )

  # Filter and sort the commands
  commands=(
    $(
      printf "%s\n" "${commands[@]}" |
        awk 'length >= 4 && !/^__/' | # Remove short commands and internal functions
        sort
    )
  )

  selected_command=$(
    printf "%s\n" "${commands[@]}" |
      fzf --layout=reverse \
          --border \
          --info=inline \
          --margin=8,20 \
          --padding=1 \
          --cycle
  )

  if [ -n "$selected_command" ]; then
    LBUFFER="${LBUFFER}${selected_command}"
  fi

  # Refresh the prompt
  zle reset-prompt
}

# Load the aliases defined in the main dotfiles directory
__select_my_command__load_global_aliases() {
  unalias -a

  local my_files file

  my_files=($DOTFILES_PATH/**/*.sh)
  my_files=(${my_files[@]/*\/lib\/*/})
  my_files=(${my_files[@]/*\/tmp\/*/})

  for file in ${my_files}; do
    source $file &> /dev/null
  done

  compgen -a
}

# Load the aliases defined in the local environment file
__select_my_command__load_local_aliases() {
  [ -f "$SHERPA_ENV_FILENAME" ] || return

  unalias -a

  source $SHERPA_ENV_FILENAME &> /dev/null

  compgen -a | sed 's/^/@/' # Prefix the alias name with '@'
}

# Load the functions defined in the main dotfiles directory
__select_my_command__load_global_functions() {
  local my_files file

  my_files=($DOTFILES_PATH/**/*.sh)
  my_files=(${my_files[@]/*\/lib\/*/})
  my_files=(${my_files[@]/*\/tmp\/*/})

  local -r filter_pattern="^[[:space:]]*([[:alnum:]_]+[[:space:]]*\(\)|function[[:space:]]+[[:alnum:]_]+)"

  for file in ${my_files}; do
    # Cleanup:
    # "function_1()" -> "function_1"
    # "function function_2()" -> "function_2()" -> "function_2"
    grep -oE "$filter_pattern" "$file" |
      sed "s/function //" |
      sed "s/()//"
  done
}

# Load the functions defined in the local environment file
__select_my_command__load_local_functions() {
  [ -f "$SHERPA_ENV_FILENAME" ] || return

  local -r filter_pattern="^[[:space:]]*([[:alnum:]_]+[[:space:]]*\(\)|function[[:space:]]+[[:alnum:]_]+)"

  # Cleanup:
  # "function_1()" -> "function_1"
  # "function function_2()" -> "function_2()" -> "function_2"
  grep -oE "$filter_pattern" "$SHERPA_ENV_FILENAME" |
    sed "s/function //" |
    sed "s/()//" |
    sed 's/^/@/' # Prefix the function name with '@'
}

zle -N __select_my_command
bindkey "^[[80;5u" __select_my_command  # Shift+Cmd+p
