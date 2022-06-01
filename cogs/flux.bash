#!/usr/bin/env bash

if type flux &>/dev/null; then
  alias f='flux' # Run kubectl
  source <(flux completion bash)
  complete -o default -F _alias_completion_wrapper f
fi

