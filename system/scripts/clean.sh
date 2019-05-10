#!/bin/bash

set -e

read -p "The clean.sh script will remove all off the user data. Continue ? [Y/N]" answer

if [ "$answer" == "${answer#[Yy]}" ]
then
    exit 0
fi

echo "Cleaning..."

# Remove files listed in gitignore
git clean -Xdf
git submodule foreach "git clean -Xdf"


