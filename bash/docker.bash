alias d='dm_wrapper && dobby'
complete -F _dobby d

alias dm='docker-machine'
complete -F _docker_machine dm

alias dc='docker-compose'
complete -F _docker-compose dc

function _dm_start_and_use() {
  machines=($(docker-machine ls -q))
  if [[ "${#machines[@]}" -eq 1 ]]; then
    machine=${machines[0]}
    echo "Found a machine $machine, starting it"
    docker-machine start "$machine"
    echo "Running 'eval $(docker-machine env "$machine")'"
    eval "$(docker-machine env "$machine")"
  else
    ehco "I don't know what to do here."
  fi
}

function _dm_use_running() { # a wrapper for a virtual docker
  running=($(docker-machine ls --filter state=Running -q))
  if [[ "${#running[@]}" -eq 1 ]]; then
    name=${running[0]}
    echo "Found running machine $name, using it"
    eval "$(docker-machine env "$name")"
  elif [[ "${#running[@]}" -gt 1 ]]; then
    echo "Found more than one running machine"
    echo "You should implement something"
  else
    _dm_start_and_use
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
    echo "Can't find docker-machine on path. "
    return 1
  fi
  _dm_use_running || _dm_use_stopped
}


#### Dobby ####

function print_dobby_usage() {
  echo "print something nice"
}

repository=brujoand

function _load_docker_image() {
  image_name=$1
  echo "Initializing image: $image_name"
  image_path=$(find . -name "$image_name" -d -print -quit)
  image_dockerfile=${image_path}/Dockerfile
  [[ -n "$repository" ]] && image_name="${repository}/${image_name}"
  container_id=$(docker ps -q --filter=ancestor="${image_name}" 2>/dev/null | head -n 1 )
}

function _list_docker_images() {
  find . -name Dockerfile -print0 | while read -r -d $'\0' s; do
    basename "$(dirname "$s")"
  done
}

function _list_running_containers() {
  docker ps --format "{{.Image}} | {{.ID}} | {{.Ports}} | {{.RunningFor}}" | column -t -s '|'
  return 0
}

function docker_clean() {
  echo "Romeving dangling images:"
  docker rmi "$(docker images -f "dangling=true" -q)"
  echo "Removing exited containers:"
  docker rm -v "$(docker ps -a -q -f status=exited)"
}

function _build_image() {
  echo "Building $image_name"
  docker build --rm -t "$image_name" "$image_path" || return 1
}


function _run_image() {
  docker run -it "${@}" --label="${image_name}"
}

function _stop_image() {
  _image_should_run
  docker stop "$container_id"
}

function _show_logs() {
  _image_should_run
  docker logs "$@" "$container_id"
}

function _exec_attached() {
  image_should_run
  docker exec -it "$container_id" "$@"
}

function _edit_dockerfile() {
  $EDITOR "$image_dockerfile"
}

function _container_should_run() {
  if ! _container_is_running; then
    echo "${image_name} is not running"
    return 1
  fi
}

function _container_is_running() {
  docker ps -q --filter="image=${image_name}" >/dev/null
  return $?
}

function dobby() {
  if [[ -n "$1" && -z "$2" ]]; then
    case $1 in
      'ls') # List available containers from current WD
        _list_docker_images
      ;;
      'ps') # List running containers
        _list_running_containers
      ;;
      'clean') # Clean up old images and containers
        clean_docker
      ;;
    esac
  elif [[ -n "$2" ]]; then
    _load_docker_image "$2"
    docker_command=$1
    shift
    shift
    case $docker_command in
    'run') # Run the <image> attached.
      _run_image "$@"
      ;;
    'stop') # Stop the <container> if running
      _stop_image
      ;;
    'exec') # Attach a shell to a running <container>
      _exec_attached "$@"
      ;;
    'logs') # Get the latest logs from a running <container>
      _show_logs "$@"
      ;;
    'edit') # Open the relevant Dockerfile in $EDITOR
      _edit_dockerfile
      ;;
    'build') # Build the image
      _build_image
      ;;
    *)
      print_dobby_usage
      ;;
    esac
  else
    print_dobby_usage
  fi
}

function _dobby() { # Autocompletion for dobby 
  local cur prev
  _get_comp_words_by_ref cur prev
  images=$(_list_docker_images)
  commands=('ls' 'ps' 'clean')
  docker_commands=('run' 'stop' 'exec' 'logs' 'edit' 'build')

  if [[ $COMP_CWORD -eq 1 ]]; then
    COMPREPLY=( $(compgen -W "${commands[*]} ${docker_commands[*]}" -- "$cur"))
  elif [[ "${commands[@]}" =~ $prev ]]; then
    COMPREPLY=()
  elif [[ "${docker_commands[@]}" =~ $prev ]]; then
    COMPREPLY=( $(compgen -W "$images" -- "$cur") )
  fi
}

complete -F _dobby dobby
