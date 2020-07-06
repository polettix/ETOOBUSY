#!/bin/sh

set -eu
: ${BLOG_PRIVATE_REPO:="private"}

if [ $# -eq 0 ] ; then
   printf >&2 '%s\n' "$0 <date-tag> <msg> <path(s)>"
   exit 1
fi

tag="$1"
commit_message="$2"
shift 2

printf >&2 'tag <%s>\ncommit message <%s>\npath(s) <%s>\nOK? (y|*) ' \
   "$tag" "$commit_message" "$*"

read x

if [ "x$x" = 'xy' ] ; then
git add "$@"
git commit -m "$commit_message"
git tag "$tag"
git push "$BLOG_PRIVATE_REPO" devel "$tag"
else
   printf >&2 'not an <y>, bailing out\n'
fi
