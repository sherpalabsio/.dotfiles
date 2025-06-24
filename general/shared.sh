# Shared between Rails and Elixir projects

t() {
  docker_compose_up || return

  # Is this an Elixir project?
  if [ -f mix.exs ]; then
    __run_tests_phoenix $1
    # Is this a Phoenix project?
    # if grep -q "phoenix" mix.exs; then
    #   __run_tests_phoenix
    # else
    #   mix run --no-halt
    # fi
  # Is this a Rails project?
  elif [ -f Gemfile ]; then
    eval "rs $@"
  else
    echo "Not a Phoenix or Rails project"
  fi
}

__run_tests_phoenix() {
  local test_file=$1

  if [ -n "$test_file" ]; then
    # Remove optional :line_number
    test_file_path=$(echo "$test_file" | sed 's/:.*//')

    # Check if the file contains "IEx.pry()"
    local -r debug_line=$(grep "IEx.pry()" "$test_file_path")
    # Check if it is not commented out
    local -r commented_out=$(echo "$debug_line" | grep "# IEx.pry()")

    if [ -n "$debug_line" ] && [ -z "$commented_out" ]; then
      iex -S mix test --trace $test_file
      return
    fi
  fi

  mix test $test_file
}

dev() {
  docker_compose_up || return

  type mid_dev_hook &> /dev/null && mid_dev_hook

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
    r server
  else
    echo "Not a Phoenix or Rails project"
  fi
}

mig() {
  docker_compose_up || return

  # Is this an Elixir project?
  if [ -f mix.exs ]; then
    mix ecto.migrate
  # Is this a Rails project?
  elif [ -f Gemfile ]; then
    eval r db:migrate
  else
    echo "Not an Elixir or Rails project"
  fi
}

rollb() {
  docker_compose_up || return

  # Is this an Elixir project?
  if [ -f mix.exs ]; then
    mix ecto.rollback
  # Is this a Rails project?
  elif [ -f Gemfile ]; then
    rails_rollback
  else
    echo "Not an Elixir or Rails project"
  fi
}

alias migt='IX_ENV=test RAILS_ENV=test mig'

# Rerun the last migration
alias migr='rollb && mig'
# Rerun the last migration for the test DB
alias migrt='MIX_ENV=test RAILS_ENV=test rollb && mig'

# Start a console (Elixir, Phoenix, Rails, or Ruby)
c() {
  docker_compose_up || return

  # Elixir project?
  if [ -f mix.exs ]; then
    iex -S mix "$@"
  # Ruby project?
  elif [ -f Gemfile ]; then
    # Rails project?
    if grep -q "rails" Gemfile; then
      eval r c "$@"
    else
      irb "$@"
    fi
  else
    irb "$@"
  fi
}
