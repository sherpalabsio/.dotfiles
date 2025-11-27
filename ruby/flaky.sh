flaky() {
  local order_param=""

  # Set default order if not provided
  if [[ "$*" != *"--order"* ]]; then
    order_param="--order defined"
  fi
  __repeat_until_fails "bin/rspec -f d $order_param $@"
}

__repeat_until_fails() {
  rm -rf tmp/reports/*(N)

  local counter=1
  local -r limit=30

  while true; do
    echo "" > log/test.log

    local round_message=" Round #$counter "
    local centered_message=$(__center_content "$round_message")
    echo "$centered_message"
    echo "$centered_message" >> log/test.log

    eval "$@"

    if [[ $? -ne 0 ]]; then
      cp log/test.log log/failed.log
      break # exit if any of the tests failed
    fi

    ((counter++))

    cp log/test.log log/success.log

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
  local total_space=$((terminal_width - content_length))
  local left_space=$((total_space / 2))

  # Create the centered line with equal signs
  local left_padding=$(printf "%*s" $left_space "")
  local right_padding=$(printf "%*s" $((total_space - left_space)) "")


  # printf "%*s" $terminal_width "" | tr ' ' '-'
  printf '─%.0s' $(seq 1 $terminal_width)
  echo "${left_padding}${content}${right_padding}"
  printf '─%.0s' $(seq 1 $terminal_width)
}

flaky__print_order_before() {
  local target_spec="${@: -1}"  # Get the last argument as target spec
  local other_args=("${@:1:$(($#-1))}")  # Get all arguments except the last one

  bin/rspec --dry-run --format json "${other_args[@]}" | \
    jq -r '.examples[].file_path' | \
    awk -v target="$target_spec" '
      {
        print $0
        if ($0 ~ target) exit
      }' | \
    awk '!seen[$0]++' | \
    sed 's|^\./||' | \
    tr '\n' ' '
}

flaky__print_order() {
  local target_spec="${@: -1}"  # Get the last argument as target spec
  local other_args=("${@:1:$(($#-1))}")  # Get all arguments except the last one

  bin/rspec --dry-run --format json "${other_args[@]}" | \
    jq -r '.examples[].file_path' | \
    sed 's|^\./||' | \
    tr '\n' ' '
}
