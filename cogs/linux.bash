# Linux specific stuff
if [[ "$(uname)" != "Linux" ]]; then
  return 0
fi

[[ -f /etc/bash_completion ]] && source /etc/bash_completion

function pbcopy {
  xclip -selection clipboard
}

function pbpaste {
  xclip -selection clipboard -o
}

