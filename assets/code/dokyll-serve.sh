#!/bin/sh
MULTICONFIG='--config _config.yml,_local_config.yml'
docker run --rm \
   -p 4000:4000 \
   -v "$PWD:/mnt" \
   -v "$PWD/_bundle:/usr/local/bundle" \
   registry.gitlab.com/polettix/dokyll \
   bundle exec jekyll serve $MULTICONFIG \
   --no-watch --skip-initial-build --host=0.0.0.0
