alias dkill='docker ps | grep -vi "container id" | cut -d " " -f1 | xargs docker stop' # Stop all running docker containers

alias d='dm_wrapper && docker' # Docker
complete -o nospace -F _docker docker d

alias dm='docker-machine'
complete -F _dm dm

alias dc='docke-compose'
complete -F _docker-compose dc

function _dm() { # Completion for wat
  local cur words
  _get_comp_words_by_ref cur
  words=$(docker-machine | grep -oE '^  ([a-z]+)' | sed 's/  \(.*\)/\1/')
  COMPREPLY=( $( compgen -W "$words" -- "$cur") )
}

function _dm_start_and_use() {
  name=$1
  docker-machine start "$name"
  eval "$(docker-machine env "$name")"
}

function _dm_use_running() { # a wrapper for a virtual docker
  running=($(docker-machine ls --filter state=Running -q))
  if [[ "${#running[@]}" -eq 1 ]]; then
    name=${running[0]}
    echo "Found running machine $name, using it"
    eval "$(docker-machine env "$name")"
  elif [[ "${#running[@]}" -gt 1 ]]; then
    echo "Found more than one running machine"
    echo "Which one should we pick?"
    _dm_start_and_use "$name"
  fi
}

function _dm_use_stopped() {
  stopped=($(docker-machine ls -q))
  if [[ "${#stopped[@]}" -eq 1 ]]; then
    name=${stopped[0]}
    echo "Found stopped machine $name, starting and using it"
    _dm_start_and_use "$name"
  elif [[ "${#running[@]}" -gt 1 ]]; then
    echo "Found more than one running machine"
    echo "Which one should we pick?"
    eval "$(docker-machine env "$name")"
  fi
}

function dm_wrapper() {
  [[ -n "$DOCKER_HOST" ]] && return

  if ! docker-machine &> /dev/null; then
    echo "Can't find docker-machine on path. :("
    return 1
  fi
  _dm_use_running || _dm_use_stopped
}
