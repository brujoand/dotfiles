#!/usr/bin/env bash

if weather_update=$(curl -s -f wttr.in/{Oslo,Nerdrum}?format='%l:+%c+%t+%p+%w'); then
  cat <<< "$weather_update" > "${HOME}/.weather_update"
fi

