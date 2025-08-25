#!/usr/bin/env bash

function set_secret() { # set a secret environment variable
  local variable_name=$1
  if [[ -z $variable_name ]]; then
    read -r -p "Variable name: " variable_name
  fi

  read -s -r -p "Password: " variable_value
  command="${variable_name}=${variable_value}"
  export "${command?}"
}
