export ERL_HISTFILE="$DROPBOX_PATH/backup/.dotfiles/.erl_history"
export ERL_AFLAGS="-kernel shell_history enabled shell_history_path '\"$ERL_HISTFILE\"'"

# Phoenix console like Rails console
alias pc='iex -S mix phx.server'

# Mix install
alias mixi='mix deps.get'
