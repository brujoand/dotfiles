function tdy() { # The today todo list
  tdy_folder="$HOME"/Dropbox/tdy
  tdy_date="$(date +'%Y.%m.%d')"
  tdy_file="${tdy_folder}/${tdy_date}.md"
  if [[ ! -f "$tdy_file" ]]; then
    echo "# ${tdy_date}" > "$tdy_file"
  fi
  "$EDITOR" "$tdy_file"
}
