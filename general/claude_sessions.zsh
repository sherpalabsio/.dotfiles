#!/bin/zsh
# Helper for the cmd+o Claude session opener (claude.sh). fzf calls it back to list, delete and filter.
# Reads CCP_DIR and CCP_BRANCH from the env that it exports.

zmodload zsh/stat zsh/datetime

readonly self=${0:A}

ago() {
  local -i secs=$(( EPOCHSECONDS - $1 ))
  if   (( secs < 3600 ));  then print -r -- "$(( secs / 60 ))m ago"
  elif (( secs < 86400 )); then print -r -- "$(( secs / 3600 ))h ago"
  else                          print -r -- "$(( secs / 86400 ))d ago"
  fi
}

# One NUL-ended entry per session, newest first:
# path <TAB> title <NL> last opened · branch
list() {
  local -r only_branch=$1
  local -a files=("$CCP_DIR"/*.jsonl(.Nom))
  (( $#files )) || return 0

  local line file value
  local -A title branch first

  # One grep over all files beats a process per session. Last title wins,
  # and a /rename (customTitle) always beats the generated one (aiTitle)
  for line in ${(f)"$(grep -oH '"aiTitle":"[^"]*"' -- $files)"}; do
    title[${line%%:*}]=${${line#*:*:\"}%\"}
  done
  for line in ${(f)"$(grep -oH '"customTitle":"[^"]*"' -- $files)"}; do
    title[${line%%:*}]=${${line#*:*:\"}%\"}
  done

  for line in ${(f)"$(grep -m1 -oH '"gitBranch":"[^"]*"' -- $files)"}; do
    branch[${line%%:*}]=${${line#*:*:\"}%\"}
  done

  # Untitled sessions fall back to my last prompt; skip the <command> wrappers
  local -a untitled
  local -A last
  for file in $files; do
    [[ -n ${title[$file]} ]] || untitled+=$file
  done
  (( $#untitled )) &&
    for line in ${(f)"$(grep -oH '"role":"user","content":"[^"<][^"]\{0,100\}' -- $untitled)"}; do
      last[${line%%:*}]=${${line#*\"content\":\"}//\\n/ }
    done

  local -a stats
  local name when
  for file in $files; do
    [[ -n $only_branch && ${branch[$file]} != $only_branch ]] && continue
    name=${title[$file]:-${last[$file]}}
    [[ -n $name ]] || continue
    zstat -A stats +mtime "$file"
    when=$(ago $stats[1])
    # Outside a git repo the branch tells nothing
    [[ -n $CCP_BRANCH ]] && when+=" · ${branch[$file]:--}"
    printf '%s\t%s\n\e[2m%s\e[0m\0' "$file" "$name" "$when"
  done
}

reload_action() {
  local filter=
  [[ $FZF_PROMPT == branch* ]] && filter=$CCP_BRANCH
  print -r -- "reload-sync(${(q)self} list ${(q)filter})${1:+$1}"
}

case $1 in
  list) list "$2" ;;
  delete)
    local file=${2%%$'\t'*}
    rm -f "$file"
    rm -rf "${file%.jsonl}"
    # Same index lands on the item below; fzf clamps it at the end of the list
    reload_action "+pos($(( FZF_POS > 1 && FZF_POS == FZF_TOTAL_COUNT ? FZF_POS - 1 : FZF_POS )))"
    ;;
  toggle)
    if [[ $FZF_PROMPT == branch* ]]; then
      FZF_PROMPT='all'
      print -r -- "change-prompt(all > )+$(reload_action)"
    else
      FZF_PROMPT='branch'
      print -r -- "change-prompt(branch: $CCP_BRANCH > )+$(reload_action)"
    fi
    ;;
esac
