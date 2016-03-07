
_sbp_powerline_disable_file="$HOME/.sbp_powerline_disable"

function _sbp_toggle_powerline() { # Enable/Disable the use of powerline font in prompt
  if [[ -f "$_sbp_powerline_disable_file" ]]; then
    rm "$_sbp_powerline_disable_file"
  else
    touch "$_sbp_powerline_disable_file"
  fi
}

function _sbp_generate_chars() { # Not using powerline font if this file exists
  if [[ -f "$_sbp_powerline_disable_file" ]]; then
    _sbp_char_segment=" "
    _sbp_char_path="/"
    _sbp_char_ready=">"
    _sbp_char_segrev=" "
  else
    _sbp_char_segment=''
    _sbp_char_path=''
    _sbp_char_ready='➜'
    _sbp_char_segrev=''
  fi
}

function _sbp_segment_append_sep() { # Takes 1 argument, the new color
  if [[ "$_sbp_prompt_left_length" -gt 0 ]]; then
    local sep_color sep_value
    if [[ "$_sbp_segment_sep_orientation" = "right" ]]; then
      sep_color=$(print_color_escapes "$_sbp_prompt_current_color" "$_sbp_segment_new_color")
      sep_value="${sep_color}${_sbp_char_segment}"
      _sbp_prompt_left_length=$(( _sbp_prompt_left_length + 2 ))
      _sbp_prompt_left_value="${_sbp_prompt_left_value}${sep_value}"
    else
      sep_color=$(print_color_escapes "$_sbp_segment_new_color" "$_sbp_prompt_current_color")
      sep_value="${sep_color}${_sbp_char_segrev}"
      _sbp_prompt_right_length=$(( _sbp_prompt_right_length + 2 ))
      _sbp_prompt_right_value="${_sbp_prompt_right_value}${sep_value}"
    fi
  fi
}

_sbp_generate_chars
