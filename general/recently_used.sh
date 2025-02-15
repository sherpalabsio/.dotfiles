# Moves the most recently used items to the top of the list
# Usage: __recently_used::merge "my_key" "value1" "value2" "value3"
__recently_used::merge() {
  local -r key=$1
  shift

  local -a current_values=("$@")
  local -a recent_values=($(__recently_used::get "$key"))
  local -a merged_values=()
  local recent_values_changed=false

  for recent_value in "${recent_values[@]}"; do
    # Does the current value exist in the recent values?
    if [[ " ${current_values[@]} " =~ " ${recent_value} " ]]; then
      # Recent value is in the current values -> remove it from the current values
      current_values=("${(@)current_values:#$recent_value}")
      merged_values+=("$recent_value")
    else
      # Recent value is NOT in the current values -> remove it from the recent values
      recent_values=("${(@)recent_values:#$recent_value}")
      recent_values_changed=true
    fi
  done

  if $recent_values_changed; then
    echo "${recent_values[@]}" > "$DOTFILES_PATH/tmp/recently_used/$key"
  fi

  merged_values+=("${current_values[@]}")
  echo "${merged_values[@]}"
}

__recently_used::get() {
  local -r key=$1

  local -r recent_values_file="$DOTFILES_PATH/tmp/recently_used/$key"

  [ -f "$recent_values_file" ] || return

  cat "$recent_values_file"
}

# Push a value to the top of the list
# Usage: __recently_used::used "my_key" "my_value"
__recently_used::used() {
  local -r MAX_RECENT_VALUES=10

  local -r key=$1
  local -r value=$2

  local -r recent_values_file="$DOTFILES_PATH/tmp/recently_used/$key"

  mkdir -p "$(dirname "$recent_values_file")"
  touch "$recent_values_file"

  local -a recent_values=($(__recently_used::get "$key"))
  recent_values=("${(@)recent_values:#$value}")
  recent_values=("$value" "${recent_values[@]}")

  # Limit the recent_values to 10 items
  recent_values=("${recent_values[1,$MAX_RECENT_VALUES]}")

  echo "${recent_values[@]}" > "$recent_values_file"
}
