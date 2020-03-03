#! /usr/bin/env bash

export TDY_PATH="$HOME/Dropbox/tdy"

alias noise='play -q -c 2 --null synth $len brownnoise band -n 2500 4000 tremolo 20 .1 reverb 50'

function tdy_done() {
  grep -R -i "$1" ${TDY_PATH} | grep '\- \[X\]'
}

function tdy() { # The today todo list
  category=${1:-work}
  tdy_folder="${TDY_PATH}/${category}"
  tdy_current_file="${tdy_folder}/$(date +'%Y/%m/%Y.%m.%d').wiki"
  tdy_current_folder="${tdy_current_file%/*}"
  tdy_previous_file=$(find "$tdy_folder" -type f -exec stat -f "%m %N" {} \; | sort -nr | head -n1 | cut -d ' '  -f 2)

  mkdir -p "${tdy_current_folder}"

  if [[ ! -f "$tdy_current_file" ]]; then
    # Replace the path and '.wiki' with equal signs
    printf '%s\n' "= $(date +'%Y.%m.%d') =" >> "$tdy_current_file"
    if [[ -f "$tdy_previous_file" ]]; then
      grep -v '[X]' "$tdy_previous_file" | grep -v '^=' | sed 's/\[o\]/[ ]/' >> "$tdy_current_file"
    fi
  fi

  if [[ -t 1 ]]; then
    "$EDITOR" "${tdy_current_file}"
  else
    # We're in a pipe, so let's cat this instead
    cat "${tdy_current_file}"
  fi
}
