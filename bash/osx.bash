# osx specific stuff
if [[ "$(uname)" == "Darwin" ]]; then
  if [ -f "$(brew --prefix)/share/bash-completion/bash_completion" ]; then
    # shellcheck source=/dev/null
    . "$(brew --prefix)/share/bash-completion/bash_completion"
  fi

  function tac() { # A hack to have tac
    awk '1 { last = NR; line[last] = $0; } END { for (i = last; i > 0; i--) { print line[i]; } }' "$1"
  }

  function woke() { # When this machine woke last
      gtac /var/log/system.log | grep -m1 "System Wake" | sed "s/\(.*\) ${HOSTNAME/.*} .*/\1/"
  }

  function _complete_ssh_hosts() { # ssh tab-completion sux on osx.
      COMPREPLY=()
      cur="${COMP_WORDS[COMP_CWORD]}"
      known=$(cut -d ' ' -f 1 ~/.ssh/known_hosts | sed -e s/,.*//g | sed 's/\[\(.*\)\].*/\1/' | sort -u)
      defined=$( [[ -f $HOME/.ssh/config ]] && sed -n 's/^Host \(.*\)/\1/p' ~/.ssh/config)
      comp_ssh_hosts="$defined\n$known"
      COMPREPLY=( $(compgen -W "${comp_ssh_hosts}" -- "$cur"))
  }

  function _notifications_enabled() {
    plutil -convert xml1 -o - ~/Library/Preferences/ByHost/com.apple.notificationcenterui.*.plist | grep -q false
  }

  function _toggle_notifications() {
    osascript <<-EOD
     tell application "System Events" to tell process "SystemUIServer"
       key down option
       click menu bar item 1 of menu bar 2
       key up option
     end tell
		EOD
  }

  function _clear_notifications() {
    osascript <<-EOD
      tell application "System Events"
        tell process "Notification Center"
          set theWindows to every window
          repeat with i from 1 to number of items in theWindows
            set this_item to item i of theWindows
              try
                click button 1 of this_item
              on error
                -- do nothing just skip
            end try
          end repeat
        end tell
      end tell
		EOD
  }

  alias stfu='_clear_notifications && _toggle_notifications'

  function _last_result() {
    osascript <<-EOD
      tell application "iTerm"
        tell current tab of current window
        get text of current session
      end tell
    end tell
		EOD
  }
fi
