#!/usr/bin/env bash

alias json_pp='python -mjson.tool' # PrettyPrint json
alias xml_pp='xmllint --format -' # PrettyPrint xml

alias strip='tr -d "\040\011\012\015"' # Remove spaces, newlines and tabs

function emoji() {
  term=$1
  if [[ -z $term ]]; then
    printf '%s\n' "We need a search term"
    return 1
  fi

  if [[ -z $EMOJI_TOKEN ]]; then
    printf '%s\n' "No \$EMOJI_TOKEN has been set"
    return 1
  fi

  curl -s "https://emoji-api.com/emojis?search=${term}&access_key=${EMOJI_TOKEN}" | jq -r '.[] | "\(.character)" ' | fzf | pbcopy
}

