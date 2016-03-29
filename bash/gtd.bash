function tdy() { # The today todo list
  tdy_folder="$HOME"/Dropbox/tdy
  tdy_date="$(date +'%Y.%m.%d')"
  tdy_file="${tdy_folder}/${tdy_date}.md"
  if [[ ! -f "$tdy_file" ]]; then
    echo "# ${tdy_date}" > "$tdy_file"
  fi
  "$EDITOR" "$tdy_file"
}

function standup() { # The today todo list
  standup_folder="$HOME"/Dropbox/Schibsted/Delivery/Standup
  [[ -d "$standup_folder" ]] || mkdir -p "$standup_folder"
  standup_date="$(date +'%Y.%m.%d')"
  standup_file="${standup_folder}/${standup_date}.md"
  if [[ ! -f "$standup_file" ]]; then
    echo "# ${standup_date}" > "$standup_file"
  fi
  "$EDITOR" "$standup_file"
}
