#!/usr/bin/env bash

if type flux &>/dev/null; then
  alias f='flux' # Run flux cli
  source <(flux completion bash)
  complete -o default -F _alias_completion_wrapper f
fi
