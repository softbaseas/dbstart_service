#!/bin/bash
git fetch origin
if [[ $(git diff origin/master -q) ]]; then
  echo "There are updates."
  echo "Updating..."
  git pull -q
  echo "Project has been updated."
  echo
else
  echo "Project already up-to-date."
fi

./src/dbstart_service.sh
