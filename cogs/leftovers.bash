#!/usr/bin/env bash

alias colors='printf "\e[%dm%d dark\e[0m  \e[%d;1m%d bold\e[0m\n" {30..37}{,,,}' # Show possible shell colors

function timer() { # takes number of hours and minutes + message and notifies you
  time_string=$1
  if [[ $time_string =~ ^[0-9]+[:][0-9]+$ ]]; then
    hours=${time_string/:*/}
    minutes=${time_string/*:/}
    seconds=$((((hours * 60) + minutes) * 60))
    time_hm="${hours}h:${minutes}m"
  elif [[ $time_string =~ ^[0-9]+$ ]]; then
    seconds=$((time_string * 60))
    time_hm="${time_string}m"
  else
    echo "error: $time_string is not a number" >&2
    return 1
  fi

  shift
  message=$*
  if [[ -z $message ]]; then
    echo "error: We need a message as well " >&2
    return 1
  fi

  (nohup terminal-notifier -title "Timer: $message" -message "Waiting for ${time_hm}" >/dev/null &)
  (nohup sleep "$seconds" >/dev/null && terminal-notifier -title "${time_hm} has passed" -sound default -message "$message" &)
}

function notification() { # Notification for osx only atm
  [[ -z $2 ]] && echo "I need a title and a message" && return

  title=$1
  message=$2

  if [[ -n "$(type terminal-notifier 2>/dev/null)" ]]; then
    (terminal-notifier -title "$title" -message "$message" &)
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    osascript -e "display notification \"$message\" with title \"$title\""
  elif [[ -n "$(type notify-send 2>/dev/null)" ]]; then
    (notify-send "$title" "$message" &)
  fi
}

function _error() { # Log an error
  >&2 echo -e "\n[ERROR]: $1"
}
