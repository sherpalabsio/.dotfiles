# For more info see the readme

autoload -Uz vcs_info
precmd() {
  vcs_info
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    directory_close="%K{$_prompt_bg2}%F{$_prompt_bg1}"
  else
    directory_close="%k%F{$_prompt_bg1}"
  fi
}

_prompt_color_rosewater="#f4dbd6"
_prompt_color_flamingo="#f0c6c6"
_prompt_color_pink="#f5bde6"
_prompt_color_mauve="#c6a0f6"
_prompt_color_red="#ed8796"
_prompt_color_maroon="#ee99a0"
_prompt_color_peach="#f5a97f"
_prompt_color_yellow="#eed49f"
_prompt_color_green="#a6da95"
_prompt_color_teal="#8bd5ca"
_prompt_color_sky="#91d7e3"
_prompt_color_sapphire="#7dc4e4"
_prompt_color_blue="#8aadf4"
_prompt_color_lavender="#b7bdf8"
_prompt_color_text="#cad3f5"
_prompt_color_subtext1="#b8c0e0"
_prompt_color_subtext0="#a5adcb"
_prompt_color_overlay2="#939ab7"
_prompt_color_overlay1="#8087a2"
_prompt_color_overlay0="#6e738d"
_prompt_color_surface2="#5b6078"
_prompt_color_surface1="#494d64"
_prompt_color_surface0="#363a4f"
_prompt_color_base="#24273a"
_prompt_color_mantle="#1e2030"
_prompt_color_crust="#181926"

_prompt_bg1="$_prompt_color_peach"
_prompt_fg1="$_prompt_color_crust"

_prompt_bg2="$_prompt_color_yellow"

# Define format for Git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:git:*' formats " %b%m %k%F{$_prompt_bg2}"
zstyle ':vcs_info:git:*' actionformats " %a%m %k%F{$_prompt_bg2}"
zstyle ':vcs_info:git*+set-message:*' hooks git-changes

+vi-git-changes() {
  # Skip if not in a Git repository
  [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] || return

  hook_com[misc]=''

  # Include the commit subject in the prompt where we stopped at
  # This is useful when a rebase stops because of conflicts or because
  # the commit was picked for editing
  if [[ -f .git/rebase-merge/message ]]; then
    local commit_message=$(head -n 1 .git/rebase-merge/message)

    if [[ $commit_message == '# This is a combination of'* ]]; then
      commit_message=$(sed -n '4p' .git/rebase-merge/message)
    fi

    hook_com[misc]=" | $commit_message"
    return
  fi

  # Do we have any changes?
  if git status --porcelain | grep -E -q '^ ?(M|A|D|R|C|\?)' &>/dev/null; then
    hook_com[misc]='!' # Add ! after the branch name if there are changes
  fi
}

PROMPT='%F{$_prompt_bg1}%K{$_prompt_bg1} %F{$_prompt_fg1}%1~%f $directory_close%F{$_prompt_fg1}${vcs_info_msg_0_}%k%f '
