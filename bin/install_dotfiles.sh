#! /usr/bin/env bash
dotfiles=$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )
bashrc=$HOME/.bashrc
src_dir=$(cd "$dotfiles/.." && pwd)

for file in "$dotfiles"/config/*; do
    link="$HOME/.${file##*/}"
    echo "Creating symlink from $link to $file"
    ln -sfn "$file" "$link" || exit 1
done

if [[ -f $bashrc ]]; then
    mv "$bashrc" "$bashrc.bac" || exit 1
    echo "Moved your old ~/.bashrc to ~/.bashrc.bac"
fi

echo "# Added by install_dotfiles.sh - $(date +"%d/%m/%y %H:%M")" > ~/.bashrc
for file in "$dotfiles"/bash/*; do
    echo ". $file" | sed "s#$HOME/#~/#" >> "$bashrc" || exit 1
done

if [[ ! -f $HOME/.bash_private ]]; then
	echo "Creating ~/.bash_private for all your personal needs."	
fi

echo -e "#Just guessing here...\nSRC_DIR=$src_dir" >> "$HOME/.bash_private" || exit 1
echo ". $HOME/.bash_private" >> "$bashrc" || exit 1
touch "$HOME/.hushlogin"

if [[ $- == *i* ]]; then 
	echo -e "\nRelaunch bash or run '. ~/.bashrc' for changes to take effect"
else
	echo -e "\nYou are currently in a login shell, and ~/.bashrc will not be read by default"
	echo "Run 'echo \". ~/.bashrc\" >> ~/.bash_profile && . ~/.bash_profile' for changes to take effect"
fi

exit 0
