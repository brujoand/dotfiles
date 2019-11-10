#!/usr/bin/env bash

brew upgrade --dry-run 2>/dev/null | grep '\->' | tr ',' '\n' | sed 's/^ //' > ${HOME}/.brew_upgrade
