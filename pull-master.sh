#!/bin/sh
set -eux
initial_branch="$(git rev-parse --abbrev-ref HEAD)"
git checkout master
git pull
git checkout "$initial_branch"
