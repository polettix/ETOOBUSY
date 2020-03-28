#!/bin/sh
MULTICONFIG='--config _config.yml,_local_config.yml'
docker run --rm \
   -v "$PWD:/mnt" \
   -v "$PWD/_bundle:/usr/local/bundle" \
   registry.gitlab.com/polettix/dokyll \
   bundle exec jekyll build $MULTICONFIG --watch --future
