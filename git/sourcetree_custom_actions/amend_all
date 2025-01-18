#!/bin/bash

# This script is used as a SourceTree custom action to amend all changes to the
# selected commit.

# SourceTree custom action settings:
# Menu caption: Amend all
# Script to run: ~/.dotfiles/git/sourcetree_custom_actions/amend_all.sh
# Parameters: $SHA

git stash

GIT_SEQUENCE_EDITOR="sed -i '' '1s/pick/edit/'" git rebase -i $1^

git stash pop
git add .
git commit --amend --no-edit
git rebase --continue
