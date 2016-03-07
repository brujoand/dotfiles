## Human readable names
_sbp_color_blue=31
_sbp_color_white=15
_sbp_color_grey=244
_sbp_color_dgrey=238
_sbp_color_lgrey=250
_sbp_color_green=148
_sbp_color_empty=0

## Color functions 
function print_color_escapes() { # prints ansi escape codes for fg and bg (optional)
  [[ -n "$2" ]] && echo -e "\[\e[38;5;${1/:/}m\e[48;5;${2/:/}m\]" && return
  [[ -n "$1" ]] && echo -e "\[\e[38;5;${1/:/}m\]"
}

_sbp_color_reset='\[\e[00m\]'

