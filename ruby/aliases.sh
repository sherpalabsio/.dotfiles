alias be='bundle exec'

alias rs='rspec'
alias t='rspec'

alias edit_arb='code ~/projects/a.rb'
alias c_arb='code ~/projects/a.rb'
alias r_arb='ruby ~/projects/a.rb'
alias run_arb='ruby ~/projects/a.rb'

# Rails
alias r4='rails _4.2.8_'
alias r5='rails _5.0.2_'
alias r6='rails _6.1.7.3_'

function r() {
  if [ -n "$USE_DOCKER_FOR_RAILS" ]; then
    docker exec -it $DOCKER_CONTAINER_NAME rails $@
  else
    rails $@
  fi
}

alias rc='r console'
alias rcs='r console --sandbox'
alias rrun='r runner'

alias routes='r routes'
alias rr_update='r routes > tmp/routes.txt' # Rails routes update
alias rr='cat tmp/routes.txt'               # Rails routes
alias rrf='rr | fzf'                        # Rails routes find (fuzzy search)

alias logd='tail -f log/development.log'
alias logt='tail -f log/test.log'

# alias rollb_normal='r db:rollback'

alias rollbt='RAILS_ENV=test r db:rollback'

alias seed='r db:seed'

alias rg='r generate'
alias rgs='r generate service'
alias rgc='r generate controller'
alias rgmig='r generate migration'
alias rgmod='r generate model'
alias rgs='r generate scaffold'

alias cop='rubocop'
alias cop_fix='rubocop --autocorrect-all'

# Other
alias lint='rubocop'
alias lint_fix='rubocop -a'

# alias rest='pumactl restart'
