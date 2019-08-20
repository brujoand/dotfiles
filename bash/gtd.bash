#! /usr/bin/env bash

function _get_last_tdy_file() {
  category=${1:-work}
  tdy_folder="$HOME/Dropbox/tdy/${category}"
  find "$tdy_folder" -type f -print0 | xargs -0 stat -f "%m %N" | sort -nr | head -n 1 | cut -d ' ' -f 2
}

function tdy() { # The today todo list
  category=${1:-work}
  tdy_folder="$HOME/Dropbox/tdy/${category}"
  year="$(date +'%Y')"
  month="$(date +'%m')"
  day="$(date +'%d')"
  date="${year}.${month}.${day}"
  tdy_current_folder="${tdy_folder}/${year}/${month}"
  tdy_current_file="${tdy_current_folder}/${date}.md"
  tdy_previous_file=$(_get_last_tdy_file)
  mkdir -p "$tdy_current_folder"
  if [[ ! -f "$tdy_current_file" ]]; then
    echo -e "# ${date}" >> "$tdy_current_file"
    if [[ -f "$tdy_previous_file" ]]; then
      grep '\[ \]' "$tdy_previous_file" | tee -a "$tdy_current_file" >/dev/null
    fi
  fi

  if [[ -t 1 ]]; then
    "$EDITOR" "${tdy_current_file}"
  else
    cat "${tdy_current_file}"
  fi
}

function standup() { # The today todo list
  standup_folder="$HOME"/Dropbox/Schibsted/Delivery/Standup
  [[ -d "$standup_folder" ]] || mkdir -p "$standup_folder"
  standup_date="$(date +'%Y.%m.%d')"
  standup_file="${standup_folder}/${standup_date}.md"
  if [[ ! -f "$standup_file" ]]; then
    echo "# ${standup_date} - $*" > "$standup_file"
  fi
  "$EDITOR" "$standup_file"
}

function meeting() { # Take notes from a meeting
  if [[ -z "$1" ]]; then
    echo "We need a meeting name / title"
    return 1
  fi
  meeting_name=$*
  meeting_filename="${meeting_name// /_}.md"
  meeting_date="$(date +'%Y.%m.%d')"
  meeting_folder="${HOME}/Dropbox/Schibsted/Delivery/Meeting/${meeting_date}"
  [[ -d "$meeting_folder" ]] || mkdir -p "$meeting_folder"
  meeting_file="${meeting_folder}/${meeting_filename}"
  if [[ ! -f "$meeting_file" ]]; then
    echo "# ${meeting_date} - $meeting_name" > "$meeting_file"
  fi
  "$EDITOR" "$meeting_file"
}
