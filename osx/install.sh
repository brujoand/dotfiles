#!/usr/bin/env bash


if [[ -z "$(type brew 2> /dev/null)" ]]; then
  echo "Installing brew.. "
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  (crontab -l 2>/dev/null; echo "* 5 * * * /usr/local/bin/brew update && /usr/local/bin/brew cask update > /dev/null") | crontab -
fi

brew update
brew upgrade --all

if [[ -z "$(brew cask 2> /dev/null)" ]]; then
  brew install caskroom/cask/brew-cask
fi

while read -r b; do
  brew install "$b"
done <brews

while read -r c; do
  brew cask install "$c"
done <casks

# Remove outdated versions from the cellar.
brew cleanup
brew cask cleanup

./setvalues.sh
git clone --depth 1 https://github.com/junegunn/fzf.git ~/opt/fzf && ~/opt/fzf/install
