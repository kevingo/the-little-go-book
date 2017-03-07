#!/bin/bash

set -e

# Build the website and copy it to the build folder
make deploy

# Commit the website and push it
cd _book

git init
git checkout -b gh-pages
git config user.name "kevingo"
git config user.email "kevingo75@gmail.com"
git add .
git commit -a -m "Auto-deploy by Travis CI"
git push --force --quiet "https://${GH_TOKEN}@github.com/kevingo/the-little-go-book.git" gh-pages:gh-pages