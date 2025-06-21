# I use this tool to jump to a line in a file using VS Code.
# For example, when an RSpec test fails, it writes the file path and line number
# of the failed expectation to the `tmp/jumper`, then I just press `cmd+j` and
# I'll be in the spec file at the line of the failed expectation.
# The same happens when I'm looking for a translated string in a Rails app.

__jump() {
  # Skip if the jumper file does not exist
  if [ ! -f tmp/jumper ]; then
    echo -n "\nThere is no jumper file"
    zle accept-line
    return
  fi

  # Skip if the jumper file is empty
  local -r jumper_content=$(cat tmp/jumper)
  if [[ -z "$jumper_content" ]]; then
    echo -n "\nEmpty jumper file"
    zle accept-line
    return
  fi

  # Select a file path from the jumper file
  local -r selected_path=$(
    cat "tmp/jumper" |
      fzf --height 20% \
          --layout=reverse \
          --select-1 \
          --cycle
  )

  zle reset-prompt

  # Skip if user hit cancel in fzf
  [ -z "$selected_path" ] && return

  code -g $selected_path
}

zle -N __jump
bindkey "^[[122;9u" __jump # cmd+j
