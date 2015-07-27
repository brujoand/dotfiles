#!/usr/bin/env bash

if [[ -z $DOTFILES ]]; then
	echo '$DOTFILES is not set, add it to your env..'
	exit 1
fi

if [[ -d .git ]]; then
  echo "Found gitrepo $(pwd)"
  ln -s $DOTFILES/githooks/jira-to-commit-msg.sh .git/hooks/prepare-commit-msg
  echo "ln -s $DOTFILES/githooks/jira-to-commit-msg.sh .git/hooks/prepare-commit-msg"
  ln -s $DOTFILES/githooks/check-linewidth.sh .git/hooks/pre-commit
  echo "ln -s $DOTFILES/githooks/untrackedfiles-at-commit.sh .git/hooks/pre-commit"
  echo "done.."
else
  echo "This is not the root of a gitrepo!"
fi
