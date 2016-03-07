function _sbp_timer_start { # Timer of last timer
  if [[ -z "$_sbp_timer_complete" && -z "$_sbp_timer" ]]; then
    _sbp_timer=$SECONDS
  else
    unset _sbp_timer_complete
  fi
}

function _sbp_timer_stop {
  local seconds=$(( SECONDS - _sbp_timer ))
  _sbp_timer_m=$(( seconds / 60 ))
  _sbp_timer_s=$(( seconds - (60 * _sbp_timer_m) ))
  _sbp_timer_complete=1
}

function _sbp_trigger_timer_hook {
  _sbp_timer_stop
  unset _sbp_timer
}

trap '_sbp_timer_start' DEBUG
