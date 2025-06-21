-- This script finds the iTerm session where the background job system (bg) is running,
-- - Sends a Ctrl+C to stop the process
-- - Starts the process again

tell application "iTerm"
  set targetSession to missing value

  -- Find the session where the background job system is running
  tell current window
    repeat with aTab in tabs
      repeat with aSession in sessions of aTab
        if name of aSession contains "bg (sidekiq" then
          set targetSession to aSession
          exit repeat
        end if
      end repeat
      if targetSession is not missing value then exit repeat
    end repeat
  end tell

  if targetSession is not missing value then
    log(do shell script "echo '==> \\033[33mHard reloading BG\\033[0m'")

    tell targetSession
      -- Send Ctrl+C
      write text (ASCII character 3) newline NO
      write text "bg"
    end tell
  end if
end tell
