# Find alias using fuzzy search then execute the selected one
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

zle -N find_alias
bindkey '^f' 'find_alias'

# Open a command plate with all the aliases and functions I defined by myself
__select_my_command() {
  local commands

  commands=(
    $(__select_my_command__load_aliases)
    $(__select_my_command__load_functions)
  )

  # Remove short items and sort the list
  commands=($(printf "%s\n" "${commands[@]}" | awk 'length >= 4' | sort))

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

__select_my_command__load_aliases() {
  unalias -a

  local my_files file

  my_files=($DOTFILES_PATH/**/*.sh)
  my_files=(${my_files[@]/*\/lib\/*/})
  my_files=(${my_files[@]/*\/tmp\/*/})

  # Add the current Sherpa env file to the list if present
  [ -f "$SHERPA_ENV_FILENAME" ] && my_files=($SHERPA_ENV_FILENAME $my_files)

  for file in ${my_files}; do
    source $file &> /dev/null
  done

  compgen -a
}

__select_my_command__load_functions() {
  local my_files file

  my_files=($DOTFILES_PATH/**/*.sh)
  my_files=(${my_files[@]/*\/lib\/*/})
  my_files=(${my_files[@]/*\/tmp\/*/})

  # Add the current Sherpa env file to the list if present
  [ -f "$SHERPA_ENV_FILENAME" ] && my_files=($SHERPA_ENV_FILENAME $my_files)

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

zle -N __select_my_command
bindkey '^p' '__select_my_command'
