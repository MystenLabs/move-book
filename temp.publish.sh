#!/usr/bin/env bash

time=$(date +%s)
# echo "time: $time"
git add .;
git commit -m "update $time";
git checkout gh-pages;
mdbook build;
git rm -r sui;
mv book sui;
git add sui;
git commit -m "update $time";
