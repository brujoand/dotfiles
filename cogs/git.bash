#!/usr/bin/env bash

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUNPUSHED=1

alias g='git' # Git
complete -o default -F _alias_completion_wrapper g
alias gs='git status' # Git status
complete -o default -F _alias_completion_wrapper gs
alias gc='git commit' # Git commit
complete -o default -F _alias_completion_wrapper gc
alias gp='git pull' # Git pull
complete -o default -F _alias_completion_wrapper gp

alias gwho='git log | sed -n "s/Author: \(.*\) <.*/\1/p" | sort | uniq -c | sort -nr | head' # Show most active commiters
alias gpb='git push -u origin $(git symbolic-ref HEAD | sed -e "s,.*/\(.*\),\1,")' # Push changes to current branch
alias gg='git grep -n'
alias gc='git clone'
alias gcb='git co "$(git branch -a | sed "s/  //" | grep -v "^*" | fzf)"'

function gshow() { # git show commits from search filter
  filter=$1
  if [[ -n "$filter" ]]; then
    commits=$(git log --pretty=format:'%h - %s' --reverse | grep -i "$filter" | cut -d ' ' -f 1 | tr '\n' ' ')
    if [[ -n "$commits" ]]; then
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

  find "$SRC_DIR" -name .git -type d -print0 | while read -r -d $'\0' gitroot; do
    echo -e "\033[1;30m\nUpdating ${gitroot%/*}:\033[0m"
    cd "${gitroot%/*}" || return 1

    if [ -z "$(git status --porcelain)" ]; then
      echo -e "\033[1;30mBranch is clean, pulling master\033[0m"
      git checkout master -q
      git pull  > /dev/null
      git checkout - -q
    fi
  done
  cd "$old_wd" || return 1
}

function gcp () { # Checkout a pull request as a branch locally, requires pull number
  if [[ -z "$1" ]]; then
    echo "We need a pull request number"
    return 1
  fi

  pr_name=pull_request_"${1}"
  git fetch origin pull/"${1}"/head:"${pr_name}" && git checkout "$pr_name"

}

function gst() { # Show git status for all dirs in cwd
  for f in "$(pwd)/"*; do
    (cd "$f" && __git_ps1 "${f}: %s\n")
  done  | column -t
}

function gpu() { # Fetch and fast forward upstream changes
  git co master && \
  git fetch upstream && \
  git merge upstream/master --ff-only
}
