# osx specific stuff
if [[ "$(uname)" == "Darwin" ]]; then
  if [ -f "$(brew --prefix)/share/bash-completion/bash_completion" ]; then
    # shellcheck source=/dev/null
    . "$(brew --prefix)/share/bash-completion/bash_completion"
  fi

  function _complete_ssh_hosts() { # ssh tab-completion sux on osx.
      COMPREPLY=()
      cur="${COMP_WORDS[COMP_CWORD]}"
      known=$(cut -d ' ' -f 1 ~/.ssh/known_hosts | sed -e s/,.*//g | sed 's/\[\(.*\)\].*/\1/' | sort -u)
      defined=$( [[ -f $HOME/.ssh/config ]] && sed -n 's/^Host \(.*\)/\1/p' ~/.ssh/config)
      comp_ssh_hosts="$defined\n$known"
      COMPREPLY=( $(compgen -W "${comp_ssh_hosts}" -- "$cur"))
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

  function status(){
    # Display brew information
    brew_upgrade=/Users/vsasanb/.brew_upgrade

    if [[ -s "$brew_upgrade" ]]; then
      printf '%s\n\n' "$(tput setaf 1)The following packages are out of date"
      cat "$brew_upgrade"
    else
      printf '%s%s\n' "$(tput sgr 2)" 'System packages are up to date!'
    fi

    printf '%s\n' "$(tput sgr 0)"

    curl wttr.in/{Oslo,Nerdrum}?format="%l:+%c+%t+%p+%w"
  }
  status

fi
