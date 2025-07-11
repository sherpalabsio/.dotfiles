# Open a command palette with all the aliases and functions I defined by myself
__command_palette() {
  local commands selected_command

  commands=(
    $(__command_palette__load_global_aliases)
    $(__command_palette__load_local_aliases)
    $(__command_palette__load_global_functions)
    $(__command_palette__load_local_functions)
  )

  # Filter and sort the commands
  commands=(
    $(
      printf "%s\n" "${commands[@]}" |
        awk 'length >= 4 && !/^__/' | # Remove short commands and internal functions
        sort
    )
  )

  commands=($(__recently_used::merge "select_my_command" "${commands[@]}"))

  selected_command=$(
    printf "%s\n" "${commands[@]}" |
      fzf --layout=reverse \
          --border \
          --info=inline \
          --margin=19%,11% \
          --padding=1 \
          --cycle \
          --border-label=" Command Palette "
  )

  if [ -n "$selected_command" ]; then
    __recently_used::add "select_my_command" "$selected_command"
    # Remove the '@' prefix
    selected_command=$(echo "$selected_command" | sed 's/^@//')

    LBUFFER="${LBUFFER}${selected_command}"
  fi

  # Refresh the prompt
  zle reset-prompt
}

# Load the aliases defined in my dotfiles
__command_palette__load_global_aliases() {
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
__command_palette__load_local_aliases() {
  local alias_name

  for alias_name in $(echo "${SHERPA_STATUS_INFO__ALIASES[@]}"); do
    echo "@$alias_name"
  done
}

# Load the functions defined in my dotfiles
__command_palette__load_global_functions() {
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
__command_palette__load_local_functions() {
  local function_name

  for function_name in $(echo "${SHERPA_STATUS_INFO__FUNCTIONS[@]}"); do
    echo "@$function_name"
  done
}

zle -N __command_palette
bindkey "^[[80;5u" __command_palette # Shift+Cmd+p
