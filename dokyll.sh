#!/bin/sh

multiconfig='--config _config.yml,_local_config.yml'
prodconfig='--config _codeberg_config.yml'
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

command="${1:-""}"
[ $# -gt 0 ] && shift

case "$command" in

   (bundle)
      dokyll bundle "$@"
      exit $?
      ;;

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

   (one-build|build-one)
      DOKYLL_PRE='' dokyll bundle exec jekyll build \
         $multiconfig --future
      exit $?
      ;;

   (build)
      DOKYLL_PRE='' dokyll bundle exec jekyll build \
         $multiconfig --watch --future
      exit $?
      ;;

   (cqbuild)
      cd _codeberg &&
      git checkout wavefront &&
      cd .. &&
      DOKYLL_PRE='' dokyll bundle exec jekyll build --future \
         $prodconfig "$@"
      ;;

   (cbuild)
      cd _codeberg &&
      git checkout wavefront &&
      cd .. &&
      DOKYLL_PRE='' dokyll bundle exec jekyll build $prodconfig "$@" &&
      cd _codeberg &&
      msg="$(git status --short --branch | sed -ne '/^??/{s/.* //;s#/$##;s#/#-#g;p}')" &&
      git add . &&
      git commit -m "Publish $msg"
      ;;

   (cpush) 
      branch="$(git rev-parse --abbrev-ref HEAD)" &&
         [ "$branch" = 'wavefront' ] &&
         count="$(git rev-list --count pages..wavefront)" &&
         [ "$count" -eq 1 ] &&
         msg="$(git log --pretty=format:%s -1)" &&
         git checkout pages &&
         git merge wavefront &&
         git reset --soft pages-root &&
         git commit -m "$msg" &&
         git branch --force wavefront &&
         git push --force
      ;;

   (cpublish)
      cd _codeberg &&
         git checkout pages &&
         branch="$(git rev-parse --abbrev-ref HEAD)" &&
         [ "$branch" = 'pages' ] &&
         cd .. &&
         DOKYLL_PRE='' dokyll bundle exec jekyll build $prodconfig "$@" &&
         cd _codeberg &&
         msg="Publish $(git status --short --branch \
            | sed -ne '/^??/{s/.* //;s#/$##;s#/#-#g;p;q}')" &&
         git add . &&
         git reset --soft pages-base &&
         git commit -m "$msg" &&
         git branch --force wavefront &&
         git push --force codeberg pages
      ;;

   (qbuild)
      DOKYLL_PRE='' dokyll bundle exec jekyll build \
         $multiconfig --watch --future --limit_posts 7
      exit $?
      ;;

   (serve)
      DOKYLL_PRE='-p 4000:4000' dokyll bundle exec jekyll serve \
         $multiconfig --no-watch --skip-initial-build --host=0.0.0.0
      exit $?
      ;;

   (build-production|production-build)
      cd _codeberg &&
      git checkout wavefront &&
      cd .. &&
      DOKYLL_PRE='' dokyll bundle exec jekyll build \
         $prodconfig "$@" &&
      cd _codeberg &&
      tag="c$(git status --short --branch | sed -ne '/^??/{s/.* //;s#/$##;s#/#-#g;p}')" &&
      git add . &&
      git commit -m "Publish $tag"
      ;;

   (*)
      cat <<EOF
"$0" [cache|build|serve)

bundle-update: run bundle update --all (might solve some issues)
cache: create _bundle cache (only needed once)
build: continuously build site as changes arise (full rebuild every time)
production-build: build site (once) for production in _codeberg
qbuild: continuously build site as changes arise (last 10 posts only)
serve: serve built site
EOF
      exit 1;
      ;;

esac
