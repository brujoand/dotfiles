alias gg='git grep -n'

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

  find "$SRC_DIR" -name .git -type d -print0 | while read -r -d $'\0' gitroot; do
    echo -e "\033[1;30m\nUpdating ${gitroot%/*}:\033[0m"
    cd "${gitroot%/*}" || return 1

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

function gst() { # Show git staatus for all dirs in cwd
  for f in "$(pwd)/"*; do
    (cd "$f" && __git_ps1 "${f}: %s\n")
  done  | column -t
}

function gpu() { # Fetch and fast forward upstream changes
  git co master && \
  git fetch upstream && \
  git merge upstream/master --ff-only
}
