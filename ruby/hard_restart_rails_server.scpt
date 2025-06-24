-- This script finds the iTerm session where a Rails server is running then
-- - Sends a Ctrl+C to stop the server
-- - Starts the server again using the dev alias

tell application "iTerm"
  set targetSession to missing value

  -- Find the session where the Rails server is running
  tell current window
    repeat with aTab in tabs
      repeat with aSession in sessions of aTab
        if name of aSession contains "dev" then
          set targetSession to aSession
          exit repeat
        end if
      end repeat
      if targetSession is not missing value then exit repeat
    end repeat
  end tell

  if targetSession is not missing value then
    log(do shell script "echo '==> \\033[33mHard reloading the Rails server\\033[0m'")

    tell targetSession
      -- Sends Ctrl+C
      write text (ASCII character 3) newline NO
      write text "dev"
    end tell
  end if
end tell
