#!/usr/bin/env bash

today=$(date +%d)
today=${today#0}

line_count=0

cal_output=$(/usr/local/bin/gcal --disable-highlighting --starting-day=1)
printf '%s\n' '|M|T|W|T|F|S|S|'
printf '%s\n' '|-|-|-|-|-|-|-|'
tail -n +4 <<< "$cal_output" | \
  sed -e 's/   / # /g' \
    -e 's/^\([0-9A-Z]\)/|\1/' \
    -e 's/ /|/g' -e 's/|\{2,\}/|/g' \
    -e "s/|\($today\)|/|__\1__|/" \
    -e 's/#/ /g'

