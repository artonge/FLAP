#!/bin/bash

# Remove files listed in gitignore
git clean -Xdf
git submodule foreach "git clean -Xdf"
