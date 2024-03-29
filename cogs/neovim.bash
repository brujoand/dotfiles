#!/usr/bin/env bash

type nvim &>/dev/null || return

alias n="$(which nvim)"
# complete -o bashdefault -o default

function nf {
  result=$(fzf)
  if [[ -n "$result" ]]; then
    nvim "$result"
  fi
}

