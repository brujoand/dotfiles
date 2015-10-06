#################################
#   Simple Bash Prompt (SBP)    #
#################################

#### Settings ####

# Alerts user if command takse longer than 'n' minutes
# Comment the line out to disable
_prompt_alert_threshold=1
# Do not generate alerts for the following commands:
_prompt_alert_ignore="vim;ssh;screen;irssi;vc;docker;v;g;d;esc;"

_color_host_fg="250" # host text color
_color_host_bg="238" # host background color
_color_path_fg="15" # path text color
_color_path_bg="31" # path background color
_color_path_sep="244" # path seperator color
_color_git_fg="238" # git text color
_color_git_bg="148" # git background color
_color_time_fg="250" # clock text color
_color_time_bg="238" # clock background color
_color_last_fg="238" # last command time text color
_color_last_bg="250" # last command time background color
_color_filler_fg=0 # the text color of the empty space (lol)
_color_filler_bg=0 # the background color of the empty space
_color_prompt_ready="238" # the color of the prompt character


#### End of settings ###


####################
# Color management #
####################

function print_color() { # prints ansi escape codes for fg and bg (optional)
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
    _prompt_segment_char=$'\uE0B0'
    _prompt_path_char=$'\uE0B1'
    _prompt_ready_char=$'\u279C'
    _prompt_segrev_char=$'\uE0B2'
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

function _prompt_generate_host {
  if [[ -n "$SSH_CLIENT" ]]; then
    _prompt_host_value="${USER}@${HOSTNAME}"
  else
    _prompt_host_value="${USER}"
  fi

  local -r host_color=$(print_color "$_color_host_fg" "$_color_host_bg")
  _prompt_host="$host_color $_prompt_host_value"
}

function _prompt_generate_path {
  local -r host_path_color=$(print_color "$_color_host_bg" "$_color_path_bg")
  local -r path_color=$(print_color "$_color_path_fg" "$_color_path_bg")
  local -r host_sep_color=$(print_color "$_color_path_sep" "$_color_path_bg")
  local -r sep=$host_sep_color$_prompt_path_char$path_color
  local -r wdir=$(pwd | sed -e "s|$HOME|~|" -e 's|^/||')
  _prompt_path="$host_path_color$_prompt_segment_char$path_color ${wdir//\// $sep }"
}

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

function _prompt_generate_git {
  if [[ -z "$_prompt_git_status" ]]; then
    local -r path_color=$(print_color "$_color_path_bg")
    _prompt_git="$_color_reset$path_color$_prompt_segment_char"
  else
    local -r path_git_color=$(print_color "$_color_path_bg" "$_color_git_bg")
    local -r git_color=$(print_color "$_color_git_fg" "$_color_git_bg")
    local -r git_end_color=$(print_color "$_color_git_bg")
    _prompt_git="$path_git_color$_prompt_segment_char$git_color $_prompt_git_status $_color_reset$git_end_color$_prompt_segment_char"
  fi
}

function _prompt_generate_filler {
  local left_prompt
  local -r wdir=$(pwd | sed "s|$HOME|~|")
  left_prompt=" $_prompt_host_value ; ${wdir//\// / } ; "
  [[ -n "$_prompt_git_status" ]] && left_prompt+="$_prompt_git_status ; "
  local -r right_prompt="; last: ${_prompt_time_m}m ${_prompt_time_s}s ; $(date +%H:%M:%S) "
  local -r columns=$(tput cols)
  local -r needed=$(( ${#left_prompt} + ${#right_prompt} ))
  local -r fillsize=$(( columns - needed ))
  local -r spaces=$(printf ' %.0s' {1..400})
  local -r color_filler=$(print_color "$_color_filler_fg" "$_color_filler_bg")
  _prompt_filler="$color_filler${spaces:0:$fillsize}"
}

function _prompt_generate_time {
  _prompt_stop_timer
  local -r time_color=$(print_color "$_color_time_fg" "$_color_time_bg")
  local -r last_color=$(print_color "$_color_last_fg" "$_color_last_bg")
  local -r last_time_color=$(print_color "$_color_last_fg" "$_color_time_fg")
  local -r fill_last_color=$(print_color "$_color_last_bg")
  _prompt_time="$fill_last_color$_prompt_segrev_char$last_color last: ${_prompt_time_m}m ${_prompt_time_s}s $last_time_color$_prompt_segrev_char$time_color \t $_color_reset$fill_last_color"
}

function _prompt_generate_alert {
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

function _prompt_generate_last_command {
  _prompt_last_command_status="$?"
  _prompt_last_command=$(history 1 | awk '{print $2}' | tr '\n' ' ' | cut -c1-30)
}

# The applying of our prompt
function set_prompt {
  _prompt_generate_last_command
  _prompt_generate_chars
  _prompt_generate_host
  _prompt_generate_time
  _prompt_generate_path
  _prompt_generate_git_status
  _prompt_generate_git
  _prompt_generate_filler
  _prompt_generate_alert

  PS1="\n\[\033]0;\w\007\]$_prompt_host $_prompt_path $_prompt_git$_prompt_filler$_prompt_time\n $_prompt_ready_char$_color_reset "
  PS2="$(print_color $_color_prompt_ready) \$_prompt_ready_char $_color_reset"
}


[[ "$PROMPT_COMMAND" == *set_prompt* ]] ||  export PROMPT_COMMAND="set_prompt;$PROMPT_COMMAND"
