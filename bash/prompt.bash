#################################
#   Simple Bash Prompt (SBP)    #
#################################

_color_blue=31
_color_white=15
_color_grey=244
_color_dgrey=238
_color_lgrey=250
_color_green=148
_color_empty=0

#### User Settings ####
# Alerts user if command tasks longer than 'n' minutes
# Comment the line out to disable
_prompt_alert_threshold=1
# Do not generate alerts for the following commands:
_prompt_alert_ignore="vim;ssh;screen;irssi;vc;docker;v;g;d;esc;"
_prompt_left_segments=('host' 'path' 'git')
_prompt_right_segments=('command' 'timestamp')
_prompt_trigger_hooks=('command' 'alert')

_color_host_fg=$_color_lgrey # host text color
_color_host_bg=$_color_dgrey # host background color
_color_path_fg=$_color_white # path text color
_color_path_bg=$_color_blue # path background color
_color_path_sep=$_color_grey # path seperator color
_color_git_fg=$_color_dgrey # git text color
_color_git_bg=$_color_green # git background color
_color_time_fg=$_color_lgrey # clock text color
_color_time_bg=$_color_dgrey # clock background color
_color_command_fg=$_color_dgrey # last command time text color
_color_command_bg=$_color_lgrey # last command time background color
_color_filler_fg=$_color_empty # the text color of the empty space (lol)
_color_filler_bg=$_color_empty # the background color of the empty space
_color_prompt_ready=$_color_dgrey # the color of the prompt character


#### End of settings ###


####################
# Color management #
####################

function print_color_escapes() { # prints ansi escape codes for fg and bg (optional)
  [[ -n "$2" ]] && echo -e "\[\e[38;5;${1}m\e[48;5;${2}m\]" && return
  [[ -n "$1" ]] && echo -e "\[\e[38;5;${1}m\]"
}

_color_reset='\[\e[00m\]'

if [[ "${USER}" == "root" ]]; then
  _color_host_fg="0"
  _color_host_bg="1"
fi

##################
# Helper methods #
##################

function prompt_toggle_powerline() { # Enable/Disable the use of powerline font in prompt
  if [[ -f "$HOME/.disable_powerline_prompt" ]]; then
    rm "$HOME/.disable_powerline_prompt"
  else
    touch "$HOME/.disable_powerline_prompt"
  fi
}

function _prompt_generate_chars() { # Not using powerline font if this file exists
  if [[ -f "$HOME/.disable_powerline_prompt" ]]; then
    _prompt_segment_char=" "
    _prompt_path_char="/"
    _prompt_ready_char=">"
    _prompt_segrev_char=" "
  else
    _prompt_segment_char=''
    _prompt_path_char=''
    _prompt_ready_char='➜'
    _prompt_segrev_char=''
  fi
}

function _prompt_alert() { # User notification
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

function _prompt_start_timer { # Timer of last command
  _prompt_timer=${_prompt_timer:-$SECONDS}
}

function _prompt_stop_timer {
  local seconds=$((SECONDS - _prompt_timer))
  unset _prompt_timer
  _prompt_time_m=$(( seconds / 60 ))
  _prompt_time_s=$(( seconds - (60 * _prompt_time_m) ))
}

trap '_prompt_start_timer' DEBUG

#############################
# Prompt segment generation #
#############################

function _prompt_generate_env {
  local env
  if [[ -n "$SSH_CLIENT" ]]; then
    env="ssh"
  fi
  if [[ -n "$STY" ]]; then
    if [[ -n "$env" ]]; then
      env=+"+screen"
    else
      env="screen"
    fi
  fi
}

function _append_segment_sep() { # Takes 1 argument, the new color
  if [[ -n "$_segment_last_color" ]]; then
    local sep_color sep_value
    if [[ "$_sep_orientation" = "right" ]]; then
      sep_color=$(print_color_escapes "$_segment_last_color" "$1")
      sep_value="${sep_color}${_prompt_segment_char}"
      _prompt_left_length=$(( _prompt_left_length + 2 ))
      _prompt_left_value="${_prompt_left_value}${sep_value}"
    else
      sep_color=$(print_color_escapes "$1" "$_segment_last_color")
      sep_value="${sep_color}${_prompt_segrev_char}"
      _prompt_right_length=$(( _prompt_right_length + 2 ))
      _prompt_right_value="${_prompt_right_value}${sep_value}"
    fi
  fi
  _segment_last_color=$1

}

function _generate_host_segment {
  local host_color host_value
  if [[ -n "$SSH_CLIENT" ]]; then
    host_value="${USER}@${HOSTNAME}"
  else
    host_value=" ${USER} "
  fi

  _append_segment_sep "$_color_host_bg"
  host_color=$(print_color_escapes "$_color_host_fg" "$_color_host_bg")
  _segment_last_length=$(( ${#host_value} + 2 ))
  _segment_last_value="${host_color}${host_value}"
}

function _generate_path_segment {
  _append_segment_sep "$_color_path_bg"
  local path_color host_sep_color sep wdir
  local path_length=0
  local path_value=
  path_color=$(print_color_escapes "$_color_path_fg" "$_color_path_bg")
  host_sep_color=$(print_color_escapes "$_color_path_sep" "$_color_path_bg")
  sep=" $host_sep_color$_prompt_path_char$path_color "
  wdir=$(pwd | sed "s|$HOME|~|")
  if [[ ${#wdir} -gt 1 ]]; then
    for folder in $(echo "$wdir" | tr '/' '\n'); do
      path_length=$(( path_length + ${#folder} + 2 + 2 ))
    done
    path_length=$(( path_length - 2 ))
    path_value=" $path_color${wdir//\// $sep } "
  else
    path_length=1
    path_value="$wdir"
  fi
  _segment_last_length=$(( path_length + 2 ))
  _segment_last_value=" $path_color${path_value} "
}

function _generate_git_segment() {
  [[ -n "$(git rev-parse --git-dir 2> /dev/null)" ]] || return 0
  local git_head git_state git_color git_value
  git_head=$(sed -e 's,.*/\(.*\),\1,' <(git symbolic-ref HEAD 2>/dev/null || git rev-parse --short HEAD))
  git_state=" $(git status --porcelain | sed -Ee 's/^(.M|M.|.R|R.) .*/\*/' -e 's/^(.A|A.) .*/\+/' -e 's/^(.D|D.) .*/\-/' | grep -oE '^(\*|\+|\?|\-)' | sort -u | tr -d '\n')"
  git_value=$git_head$git_state
  _append_segment_sep "$_color_git_bg"
  git_color=$(print_color_escapes "$_color_git_fg" "$_color_git_bg")
  _segment_last_length=$(( ${#git_value} + 2 ))
  _segment_last_value=" ${git_color}${git_value} " 
}

function _generate_prompt_segments() {
  _sep_orientation=right
  for seg in "${_prompt_left_segments[@]}"; do
    "_generate_${seg}_segment"
    _prompt_left_length=$(( _prompt_left_length + _segment_last_length ))
    _prompt_left_value="${_prompt_left_value}${_segment_last_value}"
    _segment_last_length=0
    _segment_last_value=''
  done

  _append_segment_sep $_color_filler_bg
  _sep_orientation=left

  for seg in "${_prompt_right_segments[@]}"; do
    generator="_generate_${seg}_segment"
    $generator
    _prompt_right_length=$(( _prompt_right_length + _segment_last_length ))
    _prompt_right_value="${_prompt_right_value}${_segment_last_value}"
    _segment_last_length=0
    _segment_last_value=''
  done
  _generate_filler_segment
}

function _perform_trigger_hooks() {
  for hook in "${_prompt_trigger_hooks[@]}"; do
    "_trigger_${hook}_hook"
  done
}

function _generate_filler_segment {
  local filler_length term_length spaces color_filler
  term_length=$(tput cols)
  filler_length=$(( term_length - _prompt_left_length - _prompt_right_length + 20 ))
  spaces=$(printf ' %.0s' {1..800})
  color_filler=$(print_color_escapes "$_color_filler_fg" "$_color_filler_bg")
  _prompt_filler_value="$color_filler${spaces:0:$filler_length}"
}

function _generate_timestamp_segment {
  local timestamp_color timestamp
  _append_segment_sep $_color_time_bg
  timestamp_color=$(print_color_escapes "$_color_time_fg" "$_color_time_bg")
  timestamp=$(date +%H:%M:%S)

  _segment_last_length=$(( ${#timestamp} + 1 ))
  _segment_last_value="${timestamp_color} ${timestamp} "
}

function _trigger_alert_hook {
  [[ -z "$_prompt_alert_threshold" ]] && return
  if [[ "$_prompt_alert_threshold" -le "$_prompt_time_m" ]]; then
    local title

    [[ "$_prompt_alert_ignore;" =~ $_prompt_last_command ]] && return

    if [[ "$_prompt_last_command_status" -eq "0" ]]; then
      title="Command '$_prompt_last_command' Succeded"
    else
      title="Command '$_prompt_last_command' Failed"
    fi

    _prompt_alert "$title" "Time spent: ${_prompt_time_m}m ${_prompt_time_s}s"
  fi
}

function _trigger_command_hook {
  _prompt_last_command_status="$?"
  _prompt_last_command=$(history 1 | awk '{print $2}' | cut -c1-10 | head -n 1)
  _prompt_stop_timer
}

function _generate_command_segment {
  local command_color command_value
  _append_segment_sep "$_color_command_bg"
  command_color=$(print_color_escapes "$_color_command_fg" "$_color_command_bg")
  command_value="${command_color} last: ${_prompt_time_m}m ${_prompt_time_s}s"
  
  _segment_last_length=$(( ${#command_value} + 2 ))
  _segment_last_value="${command_color} ${command_value} "
}

# The applying of our prompt
function set_prompt {
  _perform_trigger_hooks
  _prompt_left_length=-10
  _prompt_left_value=
  _prompt_right_length=0
  _prompt_right_value=
  _prompt_generate_chars
  _generate_prompt_segments
  PS1="\n${_prompt_left_value}${_prompt_filler_value}${_prompt_right_value}${_color_reset} \n$(print_color_escapes $_color_prompt_ready) ${_prompt_ready_char} ${_color_reset}"
}

[[ "$PROMPT_COMMAND" == *set_prompt* ]] ||  export PROMPT_COMMAND="set_prompt;$PROMPT_COMMAND"
