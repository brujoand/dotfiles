#! /usr/bin/env bash

if which flux &>/dev/null; then
  alias f='flux'
  complete -o default -F __start_flux g
fi

if which kubectl &>/dev/null; then
  alias k='kubectl'
  complete -o default -F __start_kubectl k
fi
