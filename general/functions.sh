readonly _ORIGINAL_BACKGROUND_PATH=~/.dotfiles/local/original_background.txt
readonly _NEW_BACKGROUND_PATH=/Volumes/DriveD/Dropbox/work/screen_casts/backround.jpg

readonly _ORIGINAL_DOCK_SIZE_PATH=~/.dotfiles/local/original_dock_size.txt
readonly _DESIRED_DOCK_SIZE=71

activate_screen_cast_env() {
  # Hide the desktop icons
  defaults write com.apple.finder CreateDesktop -bool true ; killall Finder

  # Change the background
  osascript -e 'tell application "System Events" to picture of every desktop' > $_ORIGINAL_BACKGROUND_PATH
  osascript -e 'tell application "System Events" to set picture of every desktop to "'"$_NEW_BACKGROUND_PATH"'"'

  # Change the dock size
  echo $(defaults read com.apple.dock tilesize) > $_ORIGINAL_DOCK_SIZE_PATH
  defaults write com.apple.dock tilesize -int $_DESIRED_DOCK_SIZE
  killall Dock
}

deactivate_screen_cast_env() {
  # Show the desktop icons
  defaults write com.apple.finder CreateDesktop -bool false ; killall Finder

  # Restore the background
  original_background=$(cat $_ORIGINAL_BACKGROUND_PATH)
  osascript -e 'tell application "System Events" to set picture of every desktop to "'"$original_background"'"'

  # Restore the dock size
  original_dock_size=$(cat $_ORIGINAL_DOCK_SIZE_PATH)
  defaults write com.apple.dock tilesize -int $original_dock_size
  killall Dock
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
