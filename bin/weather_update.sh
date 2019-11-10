#!/usr/bin/env bash

curl wttr.in/{Oslo,Nerdrum}?format='%l:+%c+%t+%p+%w' > ${HOME}/.weather_update

