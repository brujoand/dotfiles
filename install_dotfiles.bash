#! /usr/bin/env bash

set -e

DOTFILES=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SRC_DIR=$(cd "$DOTFILES/.." && pwd)
BASHRC=$HOME/.bashrc
CONFIG_FOLDER="$HOME"/.config
BIN_FOLDER="$HOME"/bin
PRIVATE_BASHRC="$HOME"/.bash_private

function catch_error {
  echo "Error occurred on line ${BASH_LINENO[0]} in ${BASH_SOURCE[1]}"
  echo "Failed command: $BASH_COMMAND"
  exit 1
}

trap 'catch_error' ERR

function fetch_from_git {
  local repo_name=$1
  echo "Fetching ${repo_name}"
  local repo_location="${SRC_DIR}/${repo_name}"
  if [[ -d $repo_location ]]; then
    echo "${repo_location} already exists"
  else
    git clone "https://github.com/brujoand/${repo_name}.git" "$repo_location"
    "${repo_location}/bin/install"
  fi
}

function ensure_symlink_from_to {
  local source target current_link
  source="$1"
  target="$2"

  current_link="$(readlink "$target" 2>/dev/null || true)"

  if [[ $current_link == "$source" ]]; then
    echo "Symlink from ${target} to ${source} already exists, skipping.."
  else
    if [[ -L $target && ! -e $target ]]; then
      echo "Current symlink at ${target} is broken, removing"
      rm "$target"
    elif [[ -e $target && ! -L $target ]]; then
      echo "File exists at ${target} but is not a symlink, backing up"
      mv "$target" "${target}.backup.$(date +%s)"
    fi
    echo "Creating symlink from $target to $source"
    ln -sfn "$source" "$target"
  fi
}

function link_source_to_target {
  local source="${DOTFILES}/${1}"
  local target=$2

  if [[ ! -d $target ]]; then
    echo "${target} does not exist, creating it.."
    mkdir -p "$target"
  fi

  if [[ ! -d $source ]]; then
    echo "${source} doesn't exist, nothing to do"
    return 1
  fi

  for file in "$source"/*; do
    link="$target${file##*/}"
    ensure_symlink_from_to "$file" "$link"
  done
}

function create_bashrc {
  local timestamp backuprc
  if [[ -n $BASHRC_LOADED ]]; then
    echo "dotfiles already loaded"
    return 0
  fi

  if [[ -f $BASHRC ]]; then
    timestamp="$(date +%s)"
    backuprc="${BASHRC}${timestamp}"
    mv "$BASHRC" "$backuprc"
    echo "Moved your old ${BASHRC} to ${backuprc}"
  fi

  printf '%s\n' "# Added by install_dotfiles.sh - ${timestamp}" >"$BASHRC"
  printf '%s\n' "source ${HOME}/.bashrc" >>"$HOME"/.bash_profile

}

function create_private_bashrc {
  echo "creating bashrc"
  if [[ ! -f $PRIVATE_BASHRC ]]; then
    echo "Creating $PRIVATE_BASHRC for all your personal needs."
  else
    echo "$PRIVATE_BASHRC already exists, skipping.."
    return 0
  fi

  printf '%s\n' "SRC_DIR=${SRC_DIR}" >"$PRIVATE_BASHRC"
  printf '%s\n' "DOTFILES=${DOTFILES}" >>"$PRIVATE_BASHRC"
  printf '%s\n' "source ${PRIVATE_BASHRC}" >>"$BASHRC"

}

mkdir "${HOME}/bin"
mkdir "${HOME}/opt"

link_source_to_target 'config' "${CONFIG_FOLDER}/"
link_source_to_target 'dotfiles' "${HOME}/."
link_source_to_target 'bin' "${BIN_FOLDER}/"

create_bashrc
create_private_bashrc

fetch_from_git sbc
fetch_from_git sbp

echo -e "\nReload the shell for changes to take effect"
