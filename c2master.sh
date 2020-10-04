#!/bin/sh
set -eux
[ $# -eq 0 ] && ref='devel' || ref="$1"
initial_branch="$(git rev-parse --abbrev-ref HEAD)"
git checkout master
git pull
git merge --ff-only "$ref"
git push
git checkout "$initial_branch"
[ "$initial_branch" != 'devel' ] || git push
