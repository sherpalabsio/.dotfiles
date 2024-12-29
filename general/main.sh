dev() {
  # If this is a Phoenix project, start the server
  if [ -f mix.exs ]; then
    mix phx.server
  # If this is a Rails project, start the server
  elif [ -f Gemfile ]; then
    rails server
  else
    echo "Not a Phoenix or Rails project"
  fi
}
