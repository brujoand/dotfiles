### Defaults
_sbp_path_color_bg=${_sbp_path_color_bg-:$_sbp_color_blue}
_sbp_path_color_fg=${_sbp_path_color_fg-:$_sbp_color_white}
_sbp_path_color_sep=${_sbp_path_color_sep-:$_sbp_color_grey}

function _sbp_generate_path_segment {
  local path_color sep_color sep wdir
  local path_length=0
  local path_value=
  path_color=$(print_color_escapes "$_sbp_path_color_fg" "$_sbp_path_color_bg")
  sep_color=$(print_color_escapes "$_sbp_path_color_sep" "$_sbp_path_color_bg")
  sep=" ${sep_color}${_sbp_char_path}${path_color} "
  wdir=$(pwd | sed "s|$HOME|~|")
  if [[ ${#wdir} -gt 1 ]]; then
    for folder in $(echo "$wdir" | tr '/' '\n'); do
      path_length=$(( path_length + ${#folder} + 2 + 2 ))
    done
    path_length=$(( path_length - 2 ))
    path_value=" ${wdir//\// $sep } "
  else
    path_length=2
    path_value=" $wdir "
  fi
 _sbp_segment_new_color="$_sbp_path_color_bg" 
 _sbp_segment_new_length="$(( path_length ))" 
 _sbp_segment_new_value="${path_color}${path_value}"
 _sbp_segment_new_create
}
