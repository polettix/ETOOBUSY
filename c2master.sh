#!/bin/sh
set -eux
[ $# -eq 0 ] && ref='devel' || ref="$1"
git checkout master
git pull
git merge --ff-only "$ref"
git push
git checkout devel
git push
