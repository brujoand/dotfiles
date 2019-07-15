#!/usr/bin/env bash
# Don't just carelessly push to master

protected_branch='master'
current_branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

if [[ "$protected_branch" == "$current_branch" ]]; then
  read -p "Really push to master? [y|n] " -n 1 -r < /dev/tty
  echo
  if echo "$REPLY" | grep -E '^[Yy]$' > /dev/null; then
      exit 0 # push will execute
  fi
  exit 1 # push will not execute
else
  exit 0 # push will execute
fi
