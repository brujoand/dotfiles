### Defaults
_sbp_host_color_bg=${_sbp_host_color_bg-:$_sbp_color_dgrey}
_sbp_host_color_fg=${_sbp_host_color_fg-:$_sbp_color_lgrey}

if [[ "${USER}" == "root" ]]; then
  _sbp_host_color_fg="0"
  _sbp_host_color_bg="1"
fi

function _sbp_generate_host_segment {
  local host_color host_value
  if [[ -n "$SSH_CLIENT" ]]; then
    host_value="${USER}@${HOSTNAME}"
  else
    host_value="${USER}"
  fi

  host_color=$(print_color_escapes "$_sbp_host_color_fg" "$_sbp_host_color_bg")

  _sbp_segment_new_color="$_sbp_host_color_bg" 
  _sbp_segment_new_length="$(( ${#host_value} + 2 ))" 
  _sbp_segment_new_value="${host_color} ${host_value} "
  _sbp_segment_new_create
}
