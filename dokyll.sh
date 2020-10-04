#!/bin/sh

multiconfig='--config _config.yml,_local_config.yml'
md="$(dirname "$(readlink -f "$0")")"
cachedir="$md/_bundle"

dokyll() {
   docker run --rm \
      -v "$md:/mnt" \
      -v "$cachedir:/usr/local/bundle" \
      $DOKYLL_PRE \
      registry.gitlab.com/polettix/dokyll \
      "$@"
}

case "$1" in

   (bundle-update)
      DOKYLL_PRE='' dokyll bundle update --all
      exit $?
      ;;

   (cache)
      rm -rf "$cachedir"
      mkdir -p "$cachedir"
      DOKYLL_PRE='' dokyll bundle install
      exit $?
      ;;

   (build)
      DOKYLL_PRE='' dokyll bundle exec jekyll build \
         $multiconfig --watch --future
      exit $?
      ;;

   (serve)
      DOKYLL_PRE='-p 4000:4000' dokyll bundle exec jekyll serve \
         $multiconfig --no-watch --skip-initial-build --host=0.0.0.0
      exit $?
      ;;

   (*)
      cat <<EOF
"$0" [cache|build|serve)

bundle-update: run bundle update --all (might solve some issues)
cache: create _bundle cache (only needed once)
build: continuously build site as changes arise
serve: serve built site
EOF
      exit 1;
      ;;

esac
