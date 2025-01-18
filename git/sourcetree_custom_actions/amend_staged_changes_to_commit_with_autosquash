#!/bin/bash

# This script is used as a SourceTree custom action to amend staged changes to the selected commit with autosquash.

# !!!IMPORTANT!!!: This will squash all the existing fixup commits respectively.

# SourceTree custom action settings:
# Menu caption: Amend staged (autosquash)
# Script to run: ~/.dotfiles/git/sourcetree_custom_actions/amend_staged_changes_to_commit_with_autosquash.sh
# Parameters: $SHA

git commit --fixup $1

# Check if there are any changes to stash
if [ -n "$(git status --porcelain)" ]; then
  git stash push --include-untracked
  changes_stashed=true
fi

# Rebase with autosquash without opening the editor
GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash $1^

# Pop the last stash if we stashed changes previously
if [ "$changes_stashed" = true ]; then
  git stash pop
fi
