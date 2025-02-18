-- AppleScript to run a command with arguments in the current tab of iTerm2
-- I run this script from VS Code to run RSpec and JS tests by a keyboard shortcut

-- Usage: osascript ~/.dotfiles/iTerm/run_command.scpt command argument1 argument2 ...
-- It will:
-- - Switch to iTerm2
-- - Run `command argument1 argument2 ...` in the current session

-- AppleScript in iTerm2 is deprecated

on run argv
  tell application "iTerm"
    activate

    set command to ""
    repeat with i from 1 to count of argv
      set command to command & item i of argv & " "
    end repeat

    tell current session of current window
      write text command
    end tell
  end tell
end run
