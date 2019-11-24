#! /usr/bin/env bash

dotfiles=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
bashrc=$HOME/.bashrc
src_dir=$(cd "$dotfiles/.." && pwd)
config_folder="$HOME"/.config
bin_folder="$HOME"/bin
private_bash="$HOME"/.bash_private

function ensure_symlink_exists() {
  local source target current_link
  source="$1"
  target="$2"

  current_link="$(readlink "$target")"

  if [[ "$current_link" == "$source" ]]; then
    echo "Symlink from ${target} to ${source} already exists, skipping.."
  else
    if [[ "$current_link" != "" ]]; then
      echo "Current symlink at ${target} is broken, removing"
      rm -rf "$target"
    fi
    echo "Creating symlink from $target to $source"
    ln -sfn "$source" "$target" || exit 1
  fi
}

function link_source_to_target() {
  local source="${dotfiles}/${1}"
  local target=$2

  if [[ ! -d "$target" ]]; then
    echo "${target} does not exist, creating it.."
    mkdir -p "$target"
  fi

  for file in "$source"/*; do
    link="$target${file##*/}"
    ensure_symlink_exists "$file" "$link"
  done
}


link_source_to_target "config" "$config_folder/"
link_source_to_target "dotfiles" "$HOME/."
link_source_to_target "bin" "$bin_folder/"

if [[ -f "$bashrc" ]]; then
  mv "$bashrc" "$bashrc.$(date +%s)" || exit 1
  echo "Moved your old ~/.bashrc to ~/.bashrc.bac.[timestamp]"
fi

echo "# Added by install_dotfiles.sh - $(date +"%d/%m/%y %H:%M")" > "$HOME"/.bashrc
for file in "$dotfiles"/bash/*; do
  echo "source $file" >> "$bashrc" || exit 1
done


if [[ ! -f "$private_bash" ]]; then
  echo "Creating $private_bash for all your personal needs."
  touch "$private_bash"
else
  echo "$private_bash already exists, skipping.."
fi

echo -e "SRC_DIR=$src_dir\nDOTFILES=$dotfiles" >> "$private_bash" || exit 1
echo "source $private_bash" >> "$bashrc" || exit 1

if [[ -d "$src_dir"/sbp ]];then
  echo "SPB already present, skipping"
else
  echo "Installing SPB"
  git clone git@github.com:brujoand/brujoand/sbp.git "$src_dir"/sbp
  "$src_dir"/sbp/install
fi

if ! grep -q "source ${HOME}/.bashrc" "$HOME/.bash_profile"; then
  echo "Sourcing ~/.bashrc in ~/.bash_profile to handle login shells as well."
  echo "source $HOME/.bashrc" >> "$HOME"/.bash_profile
fi

crontab=$(crontab -l 2>/dev/null)

if ! grep -q 'weather_update.sh' <<< "$crontab"; then
  echo 'Installing weather_update as crontab'
  (crontab -l 2>/dev/null; echo "0 * * * * $HOME/bin/weather_update.sh &> /dev/null") | crontab -
else
  echo 'weather_update already installed, skipping'
fi

if ! grep -q 'brew_update.sh' <<< "$crontab"; then
  echo 'Installing brew_update as crontab'
  (crontab -l 2>/dev/null; echo "0 * * * * $HOME/bin/brew_update.sh &> /dev/null") | crontab -
else
  echo 'brew_update already installed, skipping'
fi

echo -e "\nReload the shell for changes to take effect"
