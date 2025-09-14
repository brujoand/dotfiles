#!/usr/bin/env bash

_expand_alias() {
  local alias_name alias_definition
  alias_name=$1
  [[ -z $alias_name ]] && return 1
  type "$alias_name" &>/dev/null || return 1
  alias_definition=$(alias "$alias_name")
  printf '%s' "${alias_definition//alias ${alias_name}=/}"
}

_update_comp_words() {
  local alias_name alias_value
  alias_name=$1
  alias_value=$2
  [[ -z $alias_name || -z $alias_value ]] && return 1

  local alias_value_array
  read -r -a alias_value_array <<<"$alias_value"
  local comp_words=()

  for word in "${COMP_WORDS[@]}"; do
    if [[ $word == "$alias_name" ]]; then
      comp_words+=("${alias_value_array[@]}")
    else
      comp_words+=("$word")
    fi
  done

  COMP_WORDS=("${comp_words[@]}")
}

function _alias_completion_wrapper() {
  local alias_name alias_definition alias_value
  alias_name=${COMP_WORDS[0]}
  alias_value="$(_expand_alias "$alias_name")"
  [[ -z $alias_value ]] && return 1

  _update_comp_words "$alias_name" "$alias_value"
  COMP_LINE=${COMP_LINE//${alias_name}/${alias_value}}
  COMP_CWORD=$((${#COMP_WORDS[@]} - 1))
  COMP_POINT=${#COMP_LINE}

  local previous_word current_word
  current_word=${COMP_WORDS[$COMP_CWORD]}
  if [[ ${#COMP_WORDS[@]} -ge 2 ]]; then
    previous_word=${COMP_WORDS[$((COMP_CWORD - 1))]}
  fi
  local command=${COMP_WORDS[0]}
  comp_definition=$(complete -p "$command")
  comp_function=$(sed -n "s/^complete .* -F \(.*\) ${command}/\1/p" <<<"$comp_definition")

  "$comp_function" "${command}" "${current_word}" "${previous_word}"
}
