dev() {
  docker_compose_up

  # Is this an Elixir project?
  if [ -f mix.exs ]; then
    # Is this a Phoenix project?
    if grep -q "phoenix" mix.exs; then
      mix phx.server
    else
      mix run --no-halt
    fi
  # Is this a Rails project?
  elif [ -f Gemfile ]; then
    rails server
  else
    echo "Not a Phoenix or Rails project"
  fi
}

# Start a console (Elixir, Phoenix, Rails)
c() {
  docker_compose_up

  # Is this an Elixir project?
  if [ -f mix.exs ]; then
    iex -S mix
  # Is this a Rails project?
  elif [ -f Gemfile ]; then
    rails console
  else
    echo "Not supported"
  fi
}

# Print the last exit code
alias '?'='echo $?'

# Print the value of a variable
p() {
  local -r var_name=$1
  echo ${(P)var_name}
}
