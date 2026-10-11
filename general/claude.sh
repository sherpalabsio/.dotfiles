alias cc="claude --dangerously-skip-permissions"

# `ccr` resumes; any extra words become the picker's search term: `ccr asd asd`
function ccr() {
  if (( $# )); then
    claude --dangerously-skip-permissions --resume "$*"
  else
    claude --dangerously-skip-permissions --resume
  fi
}

alias ccu="cc \"/usage\""
alias manual_test_mr='cc "/mr-test-manual"'

# Claude Code temp
alias cct="cc \"/clear\" --resume \"TMP 1\""

# Takes any number of context names: `ccc engine strategies/shelf`
function ccc() {
  claude --dangerously-skip-permissions "/ctx-old $*"
}

alias cc_fork="cc --resume --fork-session"

alias ccd='cc "/ctx-old"'

alias ecc='code /Users/peter/.dotfiles/local/silverfin/Claude'
alias eccg='code /Users/peter/.claude'

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

  # A bare `return 1` from a widget only rings the bell, which looks like a crash
  if (( ! ${#files[@]} )); then
    zle -M "ccdl: no doc files under $docs_dir"
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

# Turn transcript entries into the prompt text a human actually typed
__CCRM_JQ_PRELUDE='
  def clean:
    gsub("<command-message>[^<]*</command-message>"; "")
    | gsub("<command-name>(?<n>[^<]*)</command-name>"; "\(.n)")
    | gsub("<command-args>(?<a>[^<]*)</command-args>"; " \(.a)")
    | gsub("<[^>]*>"; " ")
    | gsub("\\s+"; " ")
    | sub("^ +"; "") | sub(" +$"; "");

  def prompts:
    [ .[]
      | select(.type == "user" and (.isMeta | not) and (.isSidechain | not))
      | (.message.content
         | if type == "string" then . else [.[] | select(.type == "text").text] | join("\n") end)
      | clean
      | select(length > 0)
    ];
'

__ccrm_ago() {
  local -i secs=$(( EPOCHSECONDS - $1 ))
  (( secs < 0 )) && secs=0

  if (( secs < 3600 )); then
    print -r -- "$(( secs / 60 ))m ago"
  elif (( secs < 86400 )); then
    print -r -- "$(( secs / 3600 ))h ago"
  elif (( secs < 86400 * 30 )); then
    print -r -- "$(( secs / 86400 ))d ago"
  else
    print -r -- "$(( secs / (86400 * 30) ))mo ago"
  fi
}

# One row per session, newest first: transcript path <TAB> the columns fzf shows
__ccrm_rows() {
  local -a transcripts=("$1"/*.jsonl(.N))
  (( $#transcripts )) || return 0

  local transcript created branch prompt title line file value
  local -a stats
  local -A messages custom generated

  # Process startup dominates here, so scan every file in one grep instead of
  # spawning a pair per session
  for line in ${(f)"$(grep -cH '"type":"user"' -- $transcripts)"}; do
    messages[${line%:*}]=${line##*:}
  done

  # Titles can be rewritten mid session, so the last one in a file wins, and a
  # /rename always outranks the generated title
  for line in ${(f)"$(grep -oH -e '"customTitle":"[^"]*"' -e '"aiTitle":"[^"]*"' -- $transcripts)"}; do
    file=${line%%:*}
    value=${${line#*:*:\"}%\"}

    if [[ $line == *'"customTitle":'* ]]; then
      custom[$file]=$value
    else
      generated[$file]=$value
    fi
  done

  for transcript in $transcripts; do
    created= branch= prompt=
    zstat -A stats +mtime "$transcript"
    title=${custom[$transcript]:-${generated[$transcript]}}

    # The head of the file holds all we need except the message count, and
    # reading multi-megabyte transcripts in full is too slow for a picker
    IFS=$'\t' read -r created branch prompt < <(
      head -n 400 "$transcript" | jq -rs "
        $__CCRM_JQ_PRELUDE
        [ .[] | select(.timestamp).timestamp | sub(\"\\\\.[0-9]+Z\$\"; \"Z\") | fromdateiso8601 ] as \$times
        | [ .[] | select(.gitBranch != null).gitBranch ] as \$branches
        | [ prompts[] | select(. != \"/clear\") ] as \$asked
        | (\$asked[0] // \"(no prompt)\") as \$first
        | [ (\$times[0] // 0 | tostring),
            (\$branches[0] // \"-\"),
            # A bare '/ctx' tells nothing, so pull in the next prompt as well
            (if (\$first | length) < 30 and (\$asked[1] // \"\") != \"\"
             then \$first + \"  ·  \" + \$asked[1] else \$first end)
          ] | @tsv
      " 2>/dev/null
    )

    # Untitled sessions fall back to the first thing that was asked
    [[ -n "$title" ]] || title=${prompt:-(no prompt)}

    # The title is repeated as its own field so fzf can search it alone
    printf '%s\t %-8s %-8s %5s  %-26.26s\t%s\t%s\n' \
      "$stats[1]" \
      "$(__ccrm_ago $stats[1])" \
      "$(__ccrm_ago ${created:-$stats[1]})" \
      "${messages[$transcript]:-0}" \
      "${branch:--}" \
      "$title" \
      "$transcript"
  done | sort -rn | cut -f2-
}

__ccrm_confirm() {
  local -a lines=("$@")

  [[ $(print -l "Delete" "Cancel" | fzf \
        --height=$(( $#lines + 7 )) \
        --tabstop=1 \
        --layout=reverse \
        --border \
        --border-label=" Confirm " \
        --header="${(F)lines}" \
        --header-first \
        --pointer='>' \
        --no-info) == Delete ]]
}

# Projects can point Claude Code at their own config dir, so try those before
# the global one and take whichever actually holds transcripts
__ccrm_sessions_dir() {
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

# Claude code rm: fzf-pick sessions of a project and delete their transcripts
ccrm() {
  local -r project_path="${${1:-$PWD}:A}"
  local sessions_dir

  if ! sessions_dir=$(__ccrm_sessions_dir "$project_path"); then
    print -u2 "No Claude Code sessions for $project_path"
    return 1
  fi

  zmodload zsh/stat
  zmodload zsh/datetime

  export CCRM_JQ_PRELUDE="$__CCRM_JQ_PRELUDE"

  local rows picked transcript
  local -a selected transcripts labels

  while true; do
    rows=$(__ccrm_rows "$sessions_dir")

    if [[ -z "$rows" ]]; then
      print -r -- "No sessions left in $sessions_dir"
      break
    fi

    picked=$(print -r -- "$rows" | fzf \
      --multi \
      --delimiter=$'\t' \
      --with-nth=..2 \
      --nth=2 \
      --tabstop=1 \
      --layout=reverse \
      --border \
      --border-label=" Claude Code sessions: ${project_path:t} " \
      --header=$' Modified Created   Msgs  Branch                     Title\n Tab: mark / unmark   Ctrl-A: mark all   Enter: delete marked   Esc: quit' \
      --header-first \
      --cycle \
      --bind='ctrl-a:toggle-all' \
      --marker='✓' \
      --pointer='▸' \
      --color='marker:bright-green,pointer:bright-blue' \
      --info=inline-right \
      --preview-window='down,60%,wrap' \
      --preview 'head -n 4000 {3} | jq -rs "
          $CCRM_JQ_PRELUDE
          prompts | to_entries[] | \"[\(.key + 1)] \(.value[0:800])\n\"
        "')

    # Esc gives an empty string, and splitting that would yield one empty row
    [[ -n "$picked" ]] || break

    selected=("${(f)picked}")
    transcripts=("${(@)selected##*$'\t'}")
    labels=("${(@)selected%$'\t'*}")

    if __ccrm_confirm "Delete $#transcripts session(s)?  (Esc: back to the list)" "" $labels ""; then
      for transcript in $transcripts; do
        rm -f  "$transcript"
        # Sidecar folder with the tool results of the session
        rm -rf "${transcript%.jsonl}"
      done
      print -r -- "Deleted $#transcripts session(s)"
      break
    fi
  done

  unset CCRM_JQ_PRELUDE
}
