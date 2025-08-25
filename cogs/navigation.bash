#!/usr/bin/env bash

alias dirstat='find . -type f -not -path ".git/*" | sed "s/.*\.\(.*\)/\1/p" | grep -v "/" | sort | uniq -c | sort' # Show most common files in dir
alias top15='cut -d " " -f 1 ~/.bash_history | sort | uniq -c | sort -n |  sed "s/^ *[0-9]* //" | tail -n 15'      # Show your top 15 bash commands

function b() { # cd to a folder in current path
  local dir
  dir=$(_b | tac | fzf)
  if [[ -n $dir ]]; then
    cd "${dir}" || return 1
  fi
}

function _b() { # generate list of sub paths to current path
  local path=${PWD%/*}
  while [[ $path ]]; do
    if [[ ${path##*/} == "$1" ]]; then
      cd "$path" || return 1
      break
    else
      printf '%s\n' "$path"
      path=${path%/*}
    fi
  done
}

function backto() { # Go back to folder in path
  local path=${PWD%/*}
  while [[ $path ]]; do
    if [[ ${path##*/} == "$1" ]]; then
      cd "$path" || return 1
      break
    else
      path=${path%/*}
    fi
  done
}

function _backto() { # completion for backto
  local cur dir all
  _get_comp_words_by_ref cur
  all=$(cut -c 2- <<<"${PWD%/*}" | tr '/' '\n')
  if [[ -z $cur ]]; then
    COMPREPLY=($(compgen -W "$all"))
  else
    COMPREPLY=($(grep -i "^$cur" <(echo "${all}") | sort -u))
  fi
}
complete -o nospace -F _backto backto

function s() { # use fzf to cd into src d ir
  search_dir="$SRC_DIR"

  git_dirs=$(find "$SRC_DIR" -type d -name ".git" -maxdepth 5 -exec dirname {} \; | sed "s|$SRC_DIR||")
  result=$(fzf --border --height 20 <<<"$git_dirs")
  dir="${search_dir}/${result}"

  if [[ -d $dir ]]; then
    cd "$dir" || echo "Could not enter path ${dir}"
  fi
}

function src() { # cd into $SRC
  cd "$SRC_DIR/$1" || return 1
}

function _src() { # completion for src
  local cur temp_compreply dir

  _get_comp_words_by_ref cur
  dir=$SRC_DIR/

  if [[ $dir != "${cur:0:${#dir}}" ]]; then
    cur=${dir}${cur}
  fi

  temp_compreply=$(compgen -d "${cur}")
  COMPREPLY=(${temp_compreply[*]//$dir/})
}
complete -o nospace -S "/" -F _src src
