#!/usr/bin/env bash

type nvim &>/dev/null || return

alias n='nvim' # Run kubectl
complete -o bashdefault -o default -F _fzf_path_completion n

function nf {
  result=$(fzf)
  if [[ -n "$result" ]]; then
    nvim "$result"
  fi
}

