alias be='bundle exec'

alias rspec_with_extra_logging='rspec --format progress --format json --out tmp/jump_to_failed_rspec_line.json'
alias rs='rspec_with_extra_logging'
alias shorten_capybara_timeout='export CAPYBARA_TIMEOUT=5'
alias reset_capybara_timeout='unset CAPYBARA_TIMEOUT'
alias hard_restart_rails_server="osascript $DOTFILES_PATH/ruby/hard_restart_rails_server.scpt"

# Rails
alias r4='rails _4.2.8_'
alias r5='rails _5.0.2_'
alias r6='rails _6.1.7.3_'

alias r="rails"

alias rc='r console'
alias rcs='r console --sandbox'
alias rrun='r runner'

alias routes='r routes'
alias routes_update='r routes > tmp/routes.txt' # Rails routes update
alias rr='cat tmp/routes.txt'                   # Rails routes
alias routes_fuzzy_find='rr | fzf'              # Rails routes find (fuzzy search)

alias logd='tail -f log/development.log'
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

alias rta="rails_translation_add"

# Find the file(s) where the given text is located
rails_translation_find() {
  $HOME/projects/tools/rails_i18n_sherpa/find_file $1
}

alias rtf="rails_translation_find"

jump_to_failed_rspec_line() {
  if [ ! -f tmp/jump_to_failed_rspec_line.json ]; then
    echo -n "\nThere is no output file"
    zle accept-line
    return
  fi

  local -r failed_path_with_line_number=$(
    jq -r --arg pwd "$(pwd)" '
      [.examples[] | select(.status == "failed") |
        (.exception.backtrace | map(select(startswith($pwd))) | first)]
      | map(sub(":in .*$"; ""))[]' tmp/jump_to_failed_rspec_line.json |
      fzf --height 20% \
          --layout=reverse \
          --select-1 \
          --cycle
  )

  zle accept-line

  [ -z "$failed_path_with_line_number" ] && return

  code -g $failed_path_with_line_number
}

zle -N jump_to_failed_rspec_line
bindkey "^[[122;9u" jump_to_failed_rspec_line # Cmd+j
