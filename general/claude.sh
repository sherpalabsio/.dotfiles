alias cc="claude --dangerously-skip-permissions"

alias manual_test_mr='cc "/mr-test-manual"'

# Takes any number of context names: `ccc engine strategies/shelf`
function ccc() {
  claude --dangerously-skip-permissions "/ctx-old $*"
}

alias ccd='cc "/ctx"'

# Claude code list: fzf-pick a .claude/context(s)/**/* file, paste `ccc <name>` and run it
ccl() {
  local contexts_dir dir
  local -a files relative_files

  # Projects disagree on the plural, so take whichever one holds files
  for dir in "$(pwd)/.claude/contexts" "$(pwd)/.claude/context"; do
    files=("$dir"/**/*(.N))
    if (( ${#files[@]} )); then
      contexts_dir="$dir"
      break
    fi
  done

  # A bare `return 1` from a widget only rings the bell, which looks like a crash
  if [[ -z "$contexts_dir" ]]; then
    zle -M "ccl: no context files under $(pwd)/.claude/context(s)"
    return 0
  fi

  local file
  for file in "${files[@]}"; do
    relative_files+=("${file#$contexts_dir/}")
  done

  # Contexts are project scoped, so keep a recent list per project
  local -r recent_key="claude_contexts_${PWD//[^a-zA-Z0-9]/-}"
  local -r MAX_RECENT_CONTEXTS=5

  local -a recent_files ordered_files
  recent_files=($(__recently_used::get "$recent_key"))

  # The most recently opened ones first, dropping the ones that are gone
  for file in "${recent_files[@]}"; do
    (( ${#ordered_files} >= MAX_RECENT_CONTEXTS )) && break
    (( ${relative_files[(Ie)$file]} )) && ordered_files+=("$file")
  done

  # Everything else alphabetically
  for file in ${(o)relative_files}; do
    (( ${ordered_files[(Ie)$file]} )) || ordered_files+=("$file")
  done

  local picked
  picked=$(
    printf "%s\n" "${ordered_files[@]}" |
      fzf --multi \
          -i \
          --layout=reverse \
          --border \
          --info=inline \
          --margin=19%,11% \
          --padding=1 \
          --cycle \
          --marker='✓' \
          --pointer='▸' \
          --color='marker:bright-green,pointer:bright-blue' \
          --border-label=" Claude Contexts " \
          --header=' Tab: mark / unmark   Enter: load marked' \
          --header-first
  )

  if [[ -n "$picked" ]]; then
    local -a selected ctx_names
    selected=("${(f)picked}")

    # Last one added ends up on top, so walk backwards to keep the pick order
    local i
    for (( i = ${#selected}; i > 0; i-- )); do
      __recently_used::add "$recent_key" "${selected[i]}"
    done

    ctx_names=("${(@)selected%.*}")
    LBUFFER="${LBUFFER}ccc ${ctx_names}"
    zle accept-line
  fi

  zle reset-prompt
}
zle -N ccl
bindkey "^[[115;9u" ccl # cmd + s

# Takes any number of doc names: `ccn reports/column-editor`
function ccn() {
  claude --dangerously-skip-permissions "/ctx $*"
}

# Claude doc list: fzf-pick a doc/**/* file (or $CLAUDE_DOCS_DIR), paste `ccn <name>` and run it
ccdl() {
  local -r docs_dir="$(git rev-parse --show-toplevel 2>/dev/null || pwd)/${CLAUDE_DOCS_DIR:-doc}"
  local -a files relative_files
  files=("$docs_dir"/**/*(.N))
  files=(${files:#*_journal.md})

  # Print the error above a fresh prompt; `zle -M` leaves it pinned under the line
  if (( ! ${#files[@]} )); then
    zle -I
    print -u2 "ccdl: no doc files under $docs_dir"
    # Non-zero rings the bell
    return 0
  fi

  local file
  for file in "${files[@]}"; do
    relative_files+=("${file#$docs_dir/}")
  done

  # Docs are project scoped, so keep a recent list per project
  local -r recent_key="claude_docs_${PWD//[^a-zA-Z0-9]/-}"
  local -r MAX_RECENT_DOCS=5

  local -a recent_files ordered_files
  recent_files=($(__recently_used::get "$recent_key"))

  # The most recently opened ones first, dropping the ones that are gone
  for file in "${recent_files[@]}"; do
    (( ${#ordered_files} >= MAX_RECENT_DOCS )) && break
    (( ${relative_files[(Ie)$file]} )) && ordered_files+=("$file")
  done

  # Everything else alphabetically
  for file in ${(o)relative_files}; do
    (( ${ordered_files[(Ie)$file]} )) || ordered_files+=("$file")
  done

  local picked
  picked=$(
    printf "%s\n" "${ordered_files[@]}" |
      fzf --multi \
          -i \
          --layout=reverse \
          --border \
          --info=inline \
          --margin=19%,11% \
          --padding=1 \
          --cycle \
          --marker='✓' \
          --pointer='▸' \
          --color='marker:bright-green,pointer:bright-blue' \
          --border-label=" Team Viz Docs " \
          --header=' Tab: mark / unmark   Enter: load marked' \
          --header-first
  )

  if [[ -n "$picked" ]]; then
    local -a selected doc_names
    selected=("${(f)picked}")

    # Last one added ends up on top, so walk backwards to keep the pick order
    local i
    for (( i = ${#selected}; i > 0; i-- )); do
      __recently_used::add "$recent_key" "${selected[i]}"
    done

    doc_names=("${(@)selected%.md}")
    LBUFFER="${LBUFFER}ccn ${doc_names}"
    zle accept-line
  fi

  zle reset-prompt
}
zle -N ccdl
bindkey "^[[80;8u" ccdl # cmd + p

# Projects can point Claude Code at their own config dir, so try those before
# the global one and take whichever actually holds transcripts
__claude_sessions_dir() {
  local -r slug="${1//[^a-zA-Z0-9]/-}"
  local config_dir sessions_dir fallback
  local -a transcripts

  for config_dir in "$CLAUDE_CONFIG_DIR" "$1/.claude-config" "$HOME/.claude"; do
    [[ -n "$config_dir" ]] || continue
    sessions_dir="$config_dir/projects/$slug"
    [[ -d "$sessions_dir" ]] || continue

    transcripts=("$sessions_dir"/*.jsonl(.N))
    if (( $#transcripts )); then
      print -r -- "$sessions_dir"
      return 0
    fi

    : ${fallback:=$sessions_dir}
  done

  [[ -n "$fallback" ]] || return 1
  print -r -- "$fallback"
}

# Claude session opener: fzf over this project's sessions, newest first.
# Enter: resume   Ctrl-F: fork   Ctrl-K: delete on the spot   Ctrl-B: this branch only
__claude_sessions() {
  local -r script=~/.dotfiles/general/claude_sessions.zsh
  local sessions_dir
  if ! sessions_dir=$(__claude_sessions_dir "$PWD"); then
    zle -M "No Claude Code sessions for $PWD"
    return 0
  fi

  # fzf runs the script again on each key, so it needs these too
  local -x CCP_DIR=$sessions_dir CCP_BRANCH=$(git branch --show-current 2>/dev/null)
  local -a out
  out=("${(@f)$(
    $script list | fzf \
        --read0 --ansi --gap \
        --delimiter=$'\t' --with-nth=2.. \
        --layout=reverse --border --info=inline \
        --margin=19%,11% --padding=1 --cycle \
        --border-label=" Claude sessions: ${PWD:t} " \
        --prompt='all > ' \
        --expect=ctrl-f \
        --bind="ctrl-k:transform:$script delete {1}" \
        --bind="ctrl-b:transform:$script toggle"
  )}")

  local -r key=$out[1] id=${${out[2]%%$'\t'*}:t:r}
  if [[ -n $id ]]; then
    BUFFER="cc --resume $id"
    [[ $key == ctrl-f ]] && BUFFER+=" --fork-session"
    zle accept-line
  fi

  zle reset-prompt
}
zle -N __claude_sessions
bindkey "^[[79;8u" __claude_sessions # cmd + o
