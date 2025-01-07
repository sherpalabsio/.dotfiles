export ERL_HISTFILE="$DROPBOX_PATH/work/system/.erl_history"
export ERL_AFLAGS="-kernel shell_history enabled shell_history_path '\"$ERL_HISTFILE\"'"

# Phoenix console like Rails console
alias pc='iex -S mix phx.server'

# Elixir console like Rails console
alias ec='iex -S mix'
