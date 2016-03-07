#################################
#   Simple Bash Prompt (SBP)    #
#################################

base_folder="$HOME/src/dotfiles/bash/prompt.rc"
submodules=('helpers' 'hooks' 'segments')
for folder in "${submodules[@]}"; do
  module="${base_folder}/${folder}"
  for f in "$module"/*.bash; do
    source "$f"
  done
done

config_file="$HOME/.sbp"
if [[ -f "$config_file" ]]; then
  source "$config_file"
else
  _sbp_prompt_trigger_hooks=('timer' 'alert')
  _sbp_prompt_left_segments=('host' 'path' 'git')
  _sbp_prompt_right_segments=('command' 'timestamp')
  _sbp_prompt_ready_color="$_sbp_color_dgrey"
fi

function _sbp_segment_new_create() {
  local bg_color seg_length seg_value
  bg_color=$_sbp_segment_new_color
  seg_length=$_sbp_segment_new_length
  seg_value=$_sbp_segment_new_value

  _sbp_segment_append_sep "$bg_color"

  if [[ "$_sbp_segment_sep_orientation" == "right" ]]; then
    _sbp_prompt_left_length=$(( _sbp_prompt_left_length + seg_length ))
    _sbp_prompt_left_value="${_sbp_prompt_left_value}${seg_value}"
  else
    _sbp_prompt_right_length=$(( _sbp_prompt_right_length + seg_length ))
    _sbp_prompt_right_value="${_sbp_prompt_right_value}${seg_value}"
  fi
  _sbp_prompt_current_color=$bg_color
}

function _sbp_generate_segments() {
  _sbp_prompt_left_length=0
  _sbp_prompt_left_value=
  _sbp_prompt_right_length=0
  _sbp_prompt_right_value=
  _sbp_prompt_current_color=
  _sbp_segment_sep_orientation=right

  for seg in "${_sbp_prompt_left_segments[@]}"; do
    "_sbp_generate_${seg}_segment"
  done

  _sbp_segment_sep_orientation=left
  left_current_color=$_sbp_prompt_current_color
  _sbp_prompt_current_color=$_sbp_filler_color_bg

  for seg in "${_sbp_prompt_right_segments[@]}"; do
    _sbp_generate_${seg}_segment
  done

  _sbp_prompt_current_color=$left_current_color
  _sbp_segment_sep_orientation=right
  _sbp_generate_filler_segment
}

function _sbp_perform_trigger_hooks() {
  for hook in "${_sbp_prompt_trigger_hooks[@]}"; do
    "_sbp_trigger_${hook}_hook"
  done
}

function set_prompt {
  _sbp_current_exec_result=$?
  _sbp_current_exec_value=$(history 1 | awk '{print $2}' | cut -c1-10 | head -n 1)

  _sbp_perform_trigger_hooks
  _sbp_generate_segments
  PS1=
  #line_one="${_sbp_prompt_left_value}${_sbp_prompt_filler_value}${_sbp_prompt_right_value}${_color_reset}"
  #line_two="$(print_color_escapes $_sbp_prompt_ready_color) ${_sbp_prompt_ready_char} ${_color_reset}"
  #PS1="\n${line_one}\n${line_two}"
  PS1="\n${_sbp_prompt_left_value}${_sbp_prompt_filler_value}${_sbp_prompt_right_value}${_sbp_color_reset}\n$(print_color_escapes ${_sbp_prompt_ready_color}) ${_sbp_char_ready} ${_sbp_color_reset}"
}

[[ "$PROMPT_COMMAND" == *set_prompt* ]] ||  export PROMPT_COMMAND="set_prompt;$PROMPT_COMMAND"
