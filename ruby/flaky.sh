flaky() {
  __repeat_until_fails "bin/rspec -f d --order defined $@"
}

flaky_all() {
  __repeat_until_fails "bin/rspec -f d $@"
}

__repeat_until_fails() {
  rm -rf tmp/reports/*(N)
  echo "" > log/test.log

  local counter=1
  local -r limit=15

  while true; do
    local round_message=" Round #$counter "
    local centered_message=$(__center_content "$round_message")
    echo "$centered_message"
    echo "$centered_message" >> log/test.log

    eval "$@"

    [[ $? -ne 0 ]] && break # exit if any of the tests failed

    ((counter++))

    if ((limit < counter)); then
      echo "Limit reached ($limit)..."
      osascript -e 'display notification "Limit" with title "iTerm Notification"'
      return
    fi
  done

  osascript -e 'display notification "Failed" with title "iTerm Notification"'

  echo "FAILED"
}

__center_content() {
  local content="$1"
  local terminal_width=$(tput cols)
  local content_length=${#content}

  # Calculate padding needed on each side
  local total_padding=$((terminal_width - content_length))
  local left_padding=$((total_padding / 2))

  # Create the centered line with equal signs
  local left_equals=$(printf "%*s" $left_padding "" | tr ' ' '=')
  local right_equals=$(printf "%*s" $((total_padding - left_padding)) "" | tr ' ' '=')

  echo "${left_equals}${content}${right_equals}"
}
