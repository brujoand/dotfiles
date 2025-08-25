#!/usr/bin/env bash

alias public_ip='curl ifconfig.io'
alias local_ip='ifconfig | sed -En "s/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p"' # Whats my local ip?
alias url_encode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'        # Urlencode a string
