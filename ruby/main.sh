alias be='bundle exec'

rspec() {
  rm -f tmp/jumper_rspec.json tmp/jumper

  if [ -x "bin/rspec" ]; then
    bin/rspec "$@" --format progress --format json --out tmp/jumper_rspec.json
  else
    command rspec "$@" --format progress --format json --out tmp/jumper_rspec.json
  fi

  jq -r '
    .examples[]
    | select(.status == "failed")
    | .exception.backtrace[0]
    | split(":in") | .[0]
  ' tmp/jumper_rspec.json > tmp/jumper
}

alias rs='rspec'

alias shorten_capybara_timeout='export CAPYBARA_TIMEOUT=5'
alias reset_capybara_timeout='unset CAPYBARA_TIMEOUT'
alias hard_restart_rails_server="osascript $DOTFILES_PATH/ruby/hard_restart_rails_server.scpt"
alias hard_restart_bg="osascript $DOTFILES_PATH/ruby/hard_restart_bg.scpt"

# Rails
alias r4='rails _4.2.8_'
alias r5='rails _5.0.2_'
alias r6='rails _6.1.7.3_'

alias r='rails'

alias rcs='c --sandbox'
alias rr='r runner'

alias rout='cat tmp/routes.txt'
alias routf='routes | fzf'
alias routes_update='r routes > tmp/routes.txt && rout'

alias log='tail -f log/development.log'
alias logt='tail -f log/test.log'

alias rollb_default='r db:rollback'

alias rollbt='RAILS_ENV=test r db:rollback'

rails_rollback() {
  local -r version=$1

  if [ -n "$version" ]; then
    rollb_version $version
  else
    rollb_default
  fi
}

rails_rollback_version() {
  r db:migrate:down VERSION=$1
}

alias seed='r db:seed'

alias rg='r generate'
alias rgs='r generate service'
alias rgc='r generate controller'
alias rgmig='r generate migration'
alias rgmod='r generate model'
alias rgs='r generate scaffold'

alias lint='rubocop'
alias lint_fix='rubocop --autocorrect-all'

rails_translation_add() {
  $HOME/projects/tools/rails_i18n_sherpa/add_or_update $1
}

# Find the file(s) where the given translated english string is referenced
rails_translation_find() {
  $HOME/projects/tools/rails_i18n_sherpa/find_file $@
}
