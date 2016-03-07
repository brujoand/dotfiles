_sbp_alert_threshold="${_sbp_trigger_alert_hook:-1}"

function _sbp_alert_exec() { # User notification
  [[ -z "$2" ]] && echo "I need a title and a message" && return

  title=$1
  message=$2

  if [[ -n "$(type terminal-notifier 2> /dev/null)" ]]; then
    (terminal-notifier -title "$title" -message "$message" &)
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    osascript -e "display notification \"$message\" with title \"$title\""
  elif [[ -n "$(type notify-send 2> /dev/null)" ]]; then
    (notify-send "$title" "$message" &)
  fi
}

function _sbp_trigger_alert_hook {
  if [[ "$_sbp_alert_threshold" -le "$_sbp_timer_m" ]]; then
    local title

    if [[ "$_sbp_current_exec_status" -eq "0" ]]; then
      title="Command '$_sbp_current_exec_value' Succeded"
    else
      title="Command '$_sbp_current_exec_value' Failed"
    fi

    _sbp_alert_exec "$title" "Time spent: ${_sbp_timer_m}m ${_sbp_timer_s}s"
  fi
}
