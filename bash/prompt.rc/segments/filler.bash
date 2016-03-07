### Defaults
_sbp_filler_color_bg=${_sbp_filler_color_bg-:$_sbp_color_empty}
_sbp_filler_color_fg=${_sbp_filler_color_fg-:$_sbp_color_empty}

function _sbp_generate_filler_segment {
  local filler_length term_length spaces filler_value filler_color
  term_length=$(tput cols)
  filler_length=$(( term_length - _sbp_prompt_left_length - _sbp_prompt_right_length + 20 ))
  spaces=$(printf ' %.0s' {1..800})
  filler_color=$(print_color_escapes "$_sbp_filler_color_fg" "$_sbp_filler_color_bg")
  filler_value="${filler_color}${spaces:0:$filler_length}"
  _sbp_segment_new_color="$_sbp_filler_color_bg" 
  _sbp_segment_new_length="$(( ${#filler_value} + 2 ))" 
  _sbp_segment_new_value="${filler_color} ${filler_value} "
  _sbp_segment_new_create
}
