#!/usr/bin/env bash

function dry_run() {
  brew upgrade --dry-run 2>/dev/null
  brew cask upgrade --dry-run 2>/dev/null
}

dry_run | grep '\->' | tr ',' '\n' | sed 's/^ //' > ${HOME}/.brew_upgrade
