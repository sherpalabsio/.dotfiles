-- AppleScript to run a command with arguments in the current tab of iTerm2
-- I run this script from VS Code to run RSpec and JS tests by a keyboard shortcut

-- Usage: osascript ~/.dotfiles/iTerm/run_command.scpt command argument1 argument2 ...
-- It will:
-- - Switch to iTerm2
-- - Open a new tab if the current tab is busy running a command
-- - Clear the screen
-- - Run `command argument1 argument2 ...` in the current session

-- AppleScript in iTerm2 is deprecated

on run argv
  tell application "iTerm"
    activate


    tell current session of current window
        set sessionName to get name
    end tell

    -- Open a new tab if the current tab is busy running a command
    if sessionName does not end with "(-zsh)" then
      tell current window
          create tab with default profile
          delay 1 -- wait for the new tab to load the shell
      end tell
    end if

    set command to ""
    repeat with i from 1 to count of argv
      set command to command & item i of argv & " "
    end repeat

    tell current session of current window
      -- printf '\33c\e[3J' - This doesn't work need extra permissions
      -- but it is less smooth
      -- clear the screen - this one needs extra permissions
      tell application "System Events" to tell process "iTerm2"
        click menu item "Clear Buffer" of menu 1 of menu bar item "Edit" of menu bar 1
      end tell

      write text command
    end tell
  end tell
end run
