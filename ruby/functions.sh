rails_rollback() {
  # If there is an argument
  if [ -n "$1" ]; then
    rollb_version $1
  else
    rollb_normal
  fi
}

rails_rollback_version() {
  r db:migrate:down VERSION=$1
}
