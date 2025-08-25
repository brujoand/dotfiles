#!/usr/bin/env bash

function dry_run() {
  /usr/local/bin/brew upgrade --dry-run 2>/dev/null
  /usr/local/bin/brew --dry-run 2>/dev/null
}

dry_run | grep '\->' | tr ',' '\n' | sed 's/^ //' >"${HOME}/.brew_upgrade"
