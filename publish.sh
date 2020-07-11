#!/bin/sh

set -eu
: ${BLOG_PRIVATE_REPO:="private"}

info() { printf >&2 '%s\n' "$*"; }
die() { info "$*"; exit 1; }

publish() {
   local path=''
   local date=''
   local title=''
   local file
   for file in "$@" ; do
      case "$file" in
         (_posts/*.md)
            [ -z "$path" ] || die "two posts found, please one at a time!"
            local fm="$(sed -ne '2,/^---/{/^---/q;p}' "$file")"
            date="$(printf '%s' "$fm" \
               | teepee -y - -T '[%= (split m{\s+}mxs, V("date"))[0] %]')"
            title="$(printf '%s' "$fm" | teepee -y - -v title)"
            path="$file"
            ;;
      esac
   done

   
   [ -n "$date" ]  || die "no date from <$*>"
   [ -n "$title" ] || die "no title from <$*>"

   printf >&2 'date <%s>\ntitle <%s>\npath(s) <%s>\nOK? (y|s|*) ' \
      "$date" "$title" "$*"

   read x
   case "$x" in
      (y|Y)
         return 0
         git add "$@"
         git commit -m "New post: $title"
         git tag "$date"
         git push "$BLOG_PRIVATE_REPO" devel "$date"
         ;;
      (s|S)
         info 'skipping as requested'
         ;;
      (*)
         die 'bailing out'
         ;;
   esac

   return 0
}


[ $# -ne 0 ] || die "$0 <path(s)>"

[ "$1" != '--all' ] \
   || set -- $(git status --short --branch | sed -e '/^#/d;s/^...//')

n_posts=0
n_other=0
for file in "$@" ; do
   case "$file" in
      (_posts/*md)
         n_posts=$((n_posts + 1))
         ;;
      (*)
         n_other=$((n_other + 1))
         ;;
   esac
done

if [ $n_posts -eq 0 ] ; then
   die "no post in list <$*>"
elif [ $n_posts -eq 1 ] ; then
   publish "$@"
elif [ $n_other -eq 0 ] ; then
   for file in "$@" ; do
      publish "$file"
   done
else
   die "either one post with ancillaries, or multiple posts <$*>"
fi
