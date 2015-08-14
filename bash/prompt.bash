#################################
# Super awesome kick ass prompt #
#################################

_color_host_fg="250"
_color_host_bg="238"
_color_path_fg="15"
_color_path_bg="31"
_color_path_sep="244"
_color_git_fg="238"
_color_git_bg="148"
_color_time_fg="238"

# Colors named by foreground_background
function print_color() { # prints ansi escape codes for fg and bg (optional)
  [[ -n "$2" ]] && echo -e "\[\e[38;5;${1}m\e[48;5;${2}m\]" && return
  [[ -n "$1" ]] && echo -e "\[\e[38;5;${1}m\]"
}

_color_reset='\[\e[00m\]'

# Not using powerline font if this file exists
function _prompt_generate_chars() {
  if [[ -f "$HOME/.disable_powerline_prompt" ]]; then
    _prompt_segment_char=" "
    _prompt_path_char="/"
    _prompt_ready_char=">"
  else
    _prompt_segment_char=$'\uE0B0'
    _prompt_path_char=$'\uE0B1'
    _prompt_ready_char=$'\u279C'
  fi
}

function prompt_toggle_powerline() { # Enable/Disable the use of powerline font in prompt
  if [[ -f "$HOME/.disable_powerline_prompt" ]]; then
    rm "$HOME/.disable_powerline_prompt"
  else
    touch "$HOME/.disable_powerline_prompt"
  fi
}

# Timer
function _prompt_start_timer {
  _prompt_timer=${_prompt_timer:-$SECONDS}
}

function _prompt_stop_timer {
  local seconds=$((SECONDS - _prompt_timer))
  unset _prompt_timer
  _prompt_time_m=$(( seconds / 60 ))
  _prompt_time_s=$(( seconds - (60 * _prompt_time_m) ))
}

trap '_prompt_start_timer' DEBUG

function _prompt_generate_git_status() {
  if [[ -n "$(git rev-parse --git-dir 2> /dev/null)" ]]; then
    local git_head git_state
    git_head=$(sed -e 's,.*/\(.*\),\1,' <(git symbolic-ref HEAD 2>/dev/null || git rev-parse --short HEAD))
    git_state=" $(git status --porcelain | sed -Ee 's/^(.M|M.|.R|R.) .*/\*/' -e 's/^(.A|A.) .*/\+/' -e 's/^(.D|D.) .*/\-/' | grep -oE '^(\*|\+|\?|\-)' | sort -u | tr -d '\n')"
    _prompt_git_status=$git_head$git_state
  else
    _prompt_git_status=""
  fi
}

# Filling up the segments of the prompt
function _prompt_generate_git {
  if [[ -z "$_prompt_git_status" ]]; then
    local path_color=$(print_color "$_color_path_bg")
    _prompt_git="$_color_reset$path_color$_prompt_segment_char"
  else
    local path_git_color=$(print_color "$_color_path_bg" "$_color_git_bg")
    local git_color=$(print_color "$_color_git_fg" "$_color_git_bg")
    local git_end_color=$(print_color "$_color_git_bg")
    _prompt_git="$path_git_color$_prompt_segment_char$git_color $_prompt_git_status $_color_reset$git_end_color$_prompt_segment_char"
  fi
}


function _prompt_generate_path {
  local host_path_color=$(print_color "$_color_host_bg" "$_color_path_bg")
  local path_color=$(print_color "$_color_path_fg" "$_color_path_bg")
  local host_sep_color=$(print_color "$_color_path_sep" "$_color_path_bg")
  local sep=$host_sep_color$_prompt_path_char$path_color
  local wdir=$(pwd | sed "s|$HOME|~|")
  _prompt_path="$host_path_color$_prompt_segment_char$path_color ${wdir//\// $sep }"
}

function _prompt_generate_host {
  local host_color=$(print_color "$_color_host_fg" "$_color_host_bg")
  _prompt_host="$host_color \u@\h"
}

function _prompt_generate_filler {
  local left_prompt right_prompt columns fillsize spaces wdir needed
  wdir=$(pwd | sed "s|$HOME|~|")
  left_prompt=" $(whoami)@$(hostname -s) ; ${wdir//\// / } ; "
  [[ -n "$_prompt_git_status" ]] && left_prompt+="$_prompt_git_status ; "
  right_prompt="[last: ${_prompt_time_m}m ${_prompt_time_s}s][$(date +%H:%M:%S)]"
  columns=$(tput cols)
  needed=$(( ${#left_prompt} + ${#right_prompt} ))
  fillsize=$(( columns - needed ))
  spaces=$(printf ' %.0s' {1..400})
  _prompt_filler="$_color_reset${spaces:0:$fillsize}"
}

function _prompt_generate_time {
  _prompt_stop_timer 
  local time_color=$(print_color "$_color_time_fg")
  _prompt_time="$time_color[last: ${_prompt_time_m}m ${_prompt_time_s}s][\t]"
}

# The applying of our prompt
function set_prompt {
  _prompt_generate_host
  _prompt_generate_chars
  _prompt_generate_time
  _prompt_generate_path
  _prompt_generate_git_status
  _prompt_generate_git
  _prompt_generate_filler

  PS1="\n$_prompt_host $_prompt_path $_prompt_git$_prompt_filler$_prompt_time\n $_prompt_ready_char$_color_reset "
}

[[ "$PROMPT_COMMAND" == *set_prompt* ]] ||  export PROMPT_COMMAND="set_prompt;$PROMPT_COMMAND"
