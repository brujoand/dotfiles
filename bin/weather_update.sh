#!/usr/bin/env bash

if weather_update=$(/usr/bin/curl -s -f wttr.in/{Oslo,Nerdrum}?format='%l:+%c+%t+%p+%w'); then
  cat <<< "$weather_update" > "${HOME}/.weather_update"
fi

