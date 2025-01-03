readonly _ORIGINAL_BACKGROUND_PATH=~/.dotfiles/local/original_background.txt
readonly _NEW_BACKGROUND_PATH=/Volumes/DriveD/Dropbox/YT\ Brand/sizing_bg.jpg

readonly _ORIGINAL_DOCK_SIZE_PATH=~/.dotfiles/local/original_dock_size.txt
readonly _DESIRED_DOCK_SIZE=71

screen_cast_env__activate() {
  # Change the background
  osascript -e 'tell application "System Events" to picture of every desktop' >$_ORIGINAL_BACKGROUND_PATH
  osascript -e 'tell application "System Events" to set picture of every desktop to "'"$_NEW_BACKGROUND_PATH"'"'
}

screen_cast_env__deactivate() {
  # Restore the background
  original_background=$(cat $_ORIGINAL_BACKGROUND_PATH)
  osascript -e 'tell application "System Events" to set picture of every desktop to "'"$original_background"'"'
}

# Find alias using fuzy search then execute the selected one
find_alias() {
  # Capture the selected alias using fzf and awk
  local selected_alias
  selected_alias=$(alias | fzf | awk -F'=' '{print $1}')

  # Execute the selected alias if there is one
  if [ -n "$selected_alias" ]; then
    echo "Executing: $selected_alias"
    eval "$selected_alias"
  fi
}
