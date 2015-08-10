#! /usr/bin/env bash

[[ -z "$SRC_DIR" ]] && print_usage 

old_wd=$(pwd)

function grep_all() {
	find "$SRC_DIR" -name .git -type d -print0 | while read -d $'\0' gitroot; do
    cd "${gitroot%/*}" && result=$(git --no-pager grep --color=always "$1")
    [[ -n "$result" ]] && echo -e "\n\e[31m$(pwd):\e[0m" && echo -e "${result}"
  done
  cd "$old_wd"
}

function pull() { # do git update on master with stash for all repos in $SRC
	find "$SRC_DIR" -name .git -type d -print0 | while read -d $'\0' gitroot; do
    echo -e "\033[1;30m\nUpdating ${gitroot%/*}:\033[0m"
    cd "${gitroot%/*}" 

    if [[ -z "$(git status --porcelain | grep -v '^??')" ]]; then
      echo -e "Branch is clean, pulling master"
      git checkout master -q
      git pull  > /dev/null
      git checkout - -q
    else
      echo -e "Branch is dirty, stashing"
      git stash -q
      git checkout master -q
      echo -e "Pulling master"
      git pull > /dev/null
      git checkout - -q
      echo -e "Applying stash"
      git stash apply -q
    fi
  done
  cd "$old_wd"
}

function src() { # cd into $SRC
  cd "$SRC_DIR/$1"
}

function print_usage() {
  >&2 echo -e "\n[ERROR]: You are doing it wrong"
  exit 1
}

# This should be moved to completions.bash
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



grep_all "TODO"
