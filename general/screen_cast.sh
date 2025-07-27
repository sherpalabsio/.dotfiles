# ==============================================================================
# Screen Cast Environment

readonly _ORIGINAL_BACKGROUND_PATH=~/.dotfiles/local/original_background.txt
readonly _NEW_BACKGROUND_PATH=/Volumes/DriveD/Dropbox/Empire\ -\ collect/tech/desktop_bg/610_410.png

readonly _ORIGINAL_DOCK_SIZE_PATH=~/.dotfiles/local/original_dock_size.txt
readonly _DESIRED_DOCK_SIZE=71

screen_cast_env__activate() {
  # Change the background
  osascript -e 'tell application "System Events" to picture of every desktop' > $_ORIGINAL_BACKGROUND_PATH
  osascript -e 'tell application "System Events" to set picture of every desktop to "'"$_NEW_BACKGROUND_PATH"'"'
}

screen_cast_env__deactivate() {
  # Restore the background
  original_background=$(cat $_ORIGINAL_BACKGROUND_PATH)
  osascript -e 'tell application "System Events" to set picture of every desktop to "'"$original_background"'"'
}

screen_cast__resize() {
  local -r width=${1:-960}
  local -r height=$((width * 9 / 16))

  echo "$width X $height"

  osascript -e '
  tell application "System Events"
    tell process "Code"
      set frontmost to true
      tell window 1
        set size to {'$width', '$height'}
      end tell
    end tell
  end tell

  tell application "System Events"
    tell process "iTerm2"
      set frontmost to true
      tell window 1
        set size to {'$width', '$height'}
      end tell
    end tell
  end tell'
}
