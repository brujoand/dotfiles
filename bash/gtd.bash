function tdy() { # The today todo list
  category=${1:work}
  tdy_folder="$HOME"/Dropbox/tdy
  tdy_date="$(date +'## %Y.%m.%d')"
  tdy_file="${tdy_folder}/${category}.md"
  if ! grep -q "$tdy_date" "$tdy_file"; then
    echo -e "\n${tdy_date}" >> "$tdy_file"
  fi
  "$EDITOR" "$tdy_file"
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
