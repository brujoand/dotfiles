function cdm() { # cd into and make path if it doesn't exist
  mkdir -p "$1" && cd "$1";
}

function timer() { # takes number of minutes + message and notifies you
  time_string=$1
  if [[ "$time_string" =~ ^[0-9]+[:][0-9]+$ ]]; then
    hours=${time_string/:*/}
    minutes=${time_string/*:/}
    seconds=$(( ( (hours * 60) + minutes ) * 60 ))
    time_hm="${hours}h:${minutes}m"
  elif [[ "$time_string" =~ ^[0-9]+$ ]]; then
    seconds=$(( $time_string * 60 ))
    time_hm="${time_string}m"
  else
    echo "error: $time_string is not a number" >&2; return 1
  fi

  shift
  message=$*
  if [[ -z "$message" ]]; then
    echo "error: We need a message as well " >&2; return 1
  fi

  (nohup terminal-notifier -title "Timer: $message" -message "Waiting for ${time_hm}" > /dev/null &)
  (nohup sleep "$seconds" > /dev/null && terminal-notifier -title "${time_hm} has passed" -sound default -message "$message" &)
}

function _pvar() { # tab-completion for vhaco with ignore case
  local cur vars
  _get_comp_words_by_ref cur
  vars=$(compgen -A variable | grep -v '^_')

  if [[ -z "$cur" ]]; then
    COMPREPLY=( $( compgen -W "$vars" ) )
  else
    COMPREPLY=( $( grep -i ^"$cur" <(echo "${vars}") ) )
  fi
}
complete -F _pvar pvar

function pvar() { # echo shell variable with tab-completion
  local var="$1"
  echo "${!var}"
}

function _sourced_files(){ # Helper for sourced_files
  for f in $(sed -n 's/^[.|source] \(.*\)/\1/p' "$1"); do
    expanded=${f/#\~/$HOME}
    echo "$expanded"
    _sourced_files "$expanded"
  done
}

function sourced_files() { # Lists files which (s/w)hould have been sourced to this shell
  init_file=$(shell_init_file)
  echo "$init_file"
  _sourced_files "$init_file"
}

function list_functions() { # List all sourced functions
  for f in $(sourced_files); do
    sed -n "s/^function \(.*\)() { \(.*\)$/\1 \2/p" <(cat "$f") | grep -v "^_"
  done | sort
}

function list_aliases() { # List all sourced aliases
  for f in $(sourced_files); do
    sed -n "s/^alias \(.*\)=['|\"].*#\(.*\)$/\1 #\2/p" "$f" | sed "s/list_aliases=.*#/list_aliases #/"
  done | sort
}

function shell_init_file() { # Returns what would be your initfile
  if [[ $- == *i* ]]; then
    echo ~/.bashrc
  elif [[ -f ~/.bash_profile ]]; then
    echo ~/.bash_profile
  elif [[ -f ~/.bash_login ]]; then
    echo ~/.bash_login
  elif [[ -f ~/.profile ]]; then
    echo ~/.profile
  else
    echo "Could not find any config files.."
    exit 1
  fi
}

function esc() { # Edit a shell config file
  local file
  file=$(grep "/$1$" <(sourced_files))
  "${EDITOR:-vi}" "$file"
}

function _esc() { # Fuzzy tabcompletion for esc
  local cur config_files
  _get_comp_words_by_ref cur
  config_files=$(for file in $(sourced_files); do echo "${file##*/}"; done)

  if [[ -z "$cur" ]]; then
    COMPREPLY=( $( compgen -W "$config_files" ) )
  else
    COMPREPLY=( $(for file in $(sourced_files); do echo "${file##*/}"; done | grep -i "$cur") )
  fi
}
complete -o nospace -F _esc esc

function pp_bash() { # Pretty print bash script
  if [[ -n "$(type pygmentize 2> /dev/null)" ]]; then
   echo "${1}" | pygmentize -f terminal -l bash
  else
    echo "${1}"
  fi
}

function _wat() { # Completion for wat
  local cur words
  _get_comp_words_by_ref cur
  words=$(echo "$(list_aliases; list_functions)" | cut -d ' ' -f 1)
  COMPREPLY=( $( compgen -W "$words" -- "$cur") )
}

complete -o nospace -F _wat wat

function wat() { # show help and location of a custom function or alias
  local query
  query="$1"
  for file in $(sourced_files); do
    f_body=$(awk '/^function '"$query"'\(\)/,/^}/ { i++; if(i==1){print "# " FILENAME ":" FNR RS $0;} else {print $0;}}' "$file")
    [[ ! -z "${f_body// }" ]] && pp_bash "${f_body}"
    f_helper=$(awk '/^function \_'"$query"'\(\)/,/^}/ { i++; if(i==1){print "# " FILENAME ":" FNR RS $0;} else {print $0;}}' "$file")
    [[ ! -z "${f_helper// }" ]] && pp_bash "${f_helper}"
    a_body=$(awk '/^alias '"$query"'=/,/$/ {print "# " FILENAME ":" FNR RS $0 RS;}' $file)
    [[ ! -z "${a_body// }" ]] && pp_bash "${a_body}"
  done
  complete -p "$query" 2> /dev/null
}

function grebase() { # git pull rebase with stash
  if [ -z "$(git status --porcelain)" ]; then
    git pull --rebase
  else
    echo -e "\033[1;36m# working tree dirty - stashing changes\033[0m"
    git stash
    echo -e "\033[1;36m# pull and rebase\033[0m"
    git pull --rebase
    echo -e "\033[1;36m# applying stash\033[0m"
    git stash apply
  fi
}

function gshow() { # git show commits from search filter
  filter=$1
  if [[ ! -z "$filter" ]]; then
    commits=$(git log --pretty=format:'%h - %s' --reverse | grep -i "$filter" | cut -d ' ' -f 1 | tr '\n' ' ')
    if [[ ! -z "$commits" ]]; then
      git show "$commits"
    else
      echo 'Sorry, no commits match that filter'
    fi
  else
    echo 'I need something to search for!'
  fi
}

function gpdate() { # do git update on master with stash for all repos in $SRC
  old_wd=$(pwd)

	find "$SRC_DIR" -name .git -type d -print0 | while read -d $'\0' gitroot; do
    echo -e "\033[1;30m\nUpdating ${gitroot%/*}:\033[0m"
    cd "${gitroot%/*}"

    if [ -z "$(git status --porcelain)" ]; then
      echo -e "\033[1;30mBranch is clean, pulling master\033[0m"
      git checkout master -q
      git pull  > /dev/null
      git checkout - -q
    else
      echo -e "\033[1;31mBranch is dirty, stashing\033[0m"
      git stash -q
      git checkout master -q
      echo -e "\033[1;30mRebasing master\033[0m"
      git pull > /dev/null
      git checkout - -q
      echo -e "\033[1;31mApplying stash\033[0m"
      git stash apply -q
    fi
  done
  cd "$old_wd"
}


function backto() { # Go back to folder in path
  local path=${PWD%/*}
  while [[ $path ]]; do
    if [[ "${path##*/}" == "$1" ]]; then
      cd "$path"
      break
    else
      path=${path%/*}
    fi
  done
}

function _backto() { # completion for backto
  local cur dir all
  _get_comp_words_by_ref cur
  dir=${PWD##*/}
  all=$(PWD | cut -c 2- | tr '/' '\n')
  if [[ -z "$cur" ]]; then
    COMPREPLY=( $( compgen -W "$all") )
  else
    COMPREPLY=( $(grep -i "^$cur" <(echo "${all}") | sort -u) )
  fi
}
complete -o nospace -F _backto backto



function src() { # cd into $SRC
  cd "$SRC_DIR/$1"
}

function _src() { # completion for src
  local cur temp_compreply dir

  _get_comp_words_by_ref cur
  dir=$SRC_DIR/

  if [[ $dir != ${cur:0:${#dir}} ]]; then
    cur=${dir}${cur}
  fi

  temp_compreply=$(compgen -d "${cur}")
  COMPREPLY=( ${temp_compreply[*]//$dir/} )
}
complete -o nospace -S "/" -F _src src

function vimstall(){
  repo="$1"
  if [[ -z "$1" ]]; then
    >&2 echo -e "We need a git repo"
    return
  else
    (cd "$HOME/.vim/bundle/" && git submodule add "$repo")
  fi
}


function setjdk() { # set the active jdk with param eg 1.8
  if [ $# -ne 1 ]; then
   export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
   export PATH=$JAVA_HOME/bin:$PATH
  else
   export JAVA_HOME=$(/usr/libexec/java_home -v "$1")
   export PATH=$JAVA_HOME/bin:$PATH
  fi
}

function notification() { # Notification for osx only atm
  [[ -z "$2" ]] && echo "I need a title and a message" && return

  title=$1
  message=$2

if [[ -n "$(type terminal-notifier 2> /dev/null)" ]]; then
    (terminal-notifier -title "$title" -message "$message" &)
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    osascript -e "display notification \"$message\" with title \"$title\""
  elif [[ -n "$(type notify-send 2> /dev/null)" ]]; then
    (notify-send "$title" "$message" &)
  fi
}

function _error() { # Log an error
  >&2 echo -e "\n[ERROR]: $1"
}


