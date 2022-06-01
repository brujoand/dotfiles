#!/usr/bin/env bash

function _pvar() { # case-incensitive tab-completion for pvar
  local cur vars
  _get_comp_words_by_ref cur
  vars=$(compgen -A variable | grep -v '^_')

  if [[ -z "$cur" ]]; then
    COMPREPLY=( $( compgen -W "$vars" ) )
  else
    COMPREPLY=( $( grep -i ^"$cur" <(echo "${vars}") ) )
  fi
}
complete -F _pvar pvar

function pvar() { # echo shell variable with tab-completion
  local var="$1"
  echo "${!var}"
}

alias reload='exec $SHELL $([[ $- == *i* ]] && echo -l)' # Reload the shell
