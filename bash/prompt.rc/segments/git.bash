### Defaults
_sbp_git_color_bg=${_sbp_git_color_bg-:$_sbp_color_green}
_sbp_git_color_fg=${_sbp_git_color_fg-:$_sbp_color_dgrey}

function _sbp_generate_git_segment() {
  [[ -n "$(git rev-parse --git-dir 2> /dev/null)" ]] || return 0
  local git_head git_state git_color git_value
  git_head=$(sed -e 's,.*/\(.*\),\1,' <(git symbolic-ref HEAD 2>/dev/null || git rev-parse --short HEAD))
  git_state=" $(git status --porcelain | sed -Ee 's/^(.M|M.|.R|R.) .*/\*/' -e 's/^(.A|A.) .*/\+/' -e 's/^(.D|D.) .*/\-/' | grep -oE '^(\*|\+|\?|\-)' | sort -u | tr -d '\n')"
  git_color=$(print_color_escapes "$_sbp_git_color_fg" "$_sbp_git_color_bg")
  git_value="${git_head}${git_state}"
  _sbp_segment_new_color="$_sbp_git_color_bg" 
  _sbp_segment_new_length="$(( ${#git_value} + 2 ))" 
  _sbp_segment_new_value="${git_color} ${git_value} "
  _sbp_segment_new_create
}
