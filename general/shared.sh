# Shared between Rails and Elixir projects

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
    r server
  else
    echo "Not a Phoenix or Rails project"
  fi
}

mig() {
  docker_compose_up

  # Is this an Elixir project?
  if [ -f mix.exs ]; then
    mix ecto.migrate
  # Is this a Rails project?
  elif [ -f Gemfile ]; then
    r db:migrate
  else
    echo "Not an Elixir or Rails project"
  fi
}

rollb() {
  docker_compose_up

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

# Start a console (Elixir, Phoenix, Rails)
c() {
  docker_compose_up

  # Is this an Elixir project?
  if [ -f mix.exs ]; then
    iex -S mix
  # Is this a Rails project?
  elif [ -f Gemfile ]; then
    # Does the gemfile have rails?
    if grep -q "rails" Gemfile; then
      rc
    else
      irb
    fi
  else
    irb
  fi
}
