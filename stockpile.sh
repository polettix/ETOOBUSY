#!/bin/sh

set -eu
: ${BLOG_PRIVATE_REPO:="private"}

info() { printf >&2 '%s\n' "$*"; }
die() { info "$*"; exit 1; }

new_branch_name() {
   local candidate="stockpile/item-$(date -u '+%Y%m%d%H%M%S')"
   local suffix='0'
   while git rev-parse "$candidate-$suffix" >/dev/null 2>&1 ; do
      suffix=$((suffix + 1))
   done
   printf '%s' "$candidate-$suffix"
}

stockpile() {
   local path=''
   local date=''
   local title=''
   local file
   for file in "$@" ; do
      case "$file" in
         (_posts/*.md)
            [ -z "$path" ] || die "two posts found, please one at a time!"
            local fm="$(sed -ne '2,/^---/{/^---/q;p}' "$file")"
            title="$(printf '%s' "$fm" | teepee -y - -v title)"
            path="$file"
            ;;
      esac
   done

   [ -n "$title" ] || die "no title from <$*>"

   printf >&2 'title <%s>\npath(s) <%s>\nOK? (y|s|*) ' "$title" "$*"

   read x
   case "$x" in
      (y|Y)
         : # will actually do something outside the case/esac pair
         ;;
      (s|S)
         info 'skipping as requested'
         return 0
         ;;
      (*)
         die 'bailing out'
         ;;
   esac

   # save current branch for later and create the new one
   local initial_branch="$(git rev-parse --abbrev-ref HEAD)"
   local new_branch="$(new_branch_name)"
   git checkout -b "$new_branch"

   git add "$@"
   git commit -m "New post: $title"
   git push "$BLOG_PRIVATE_REPO" "$new_branch"

   # return to initial branch, for next loop or exiting cleanly
   git checkout "$initial_branch"

   return 0
}

command_add() {
   if [ "${1:-"--all"}" = '--all' ]; then
      set -- $(git status --short --branch | sed -e '/^#/d;s/^...//')
   fi

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
      stockpile "$@"
   elif [ $n_other -eq 0 ] ; then
      for file in "$@" ; do
         stockpile "$file"
      done
   else
      die "either one post with ancillaries, or multiple posts <$*>"
   fi
}

command_list() {
   git branch -av \
      | sed -ne '/^..stockpile\/item-/{s/^..//;s/  *[^ ]* */ | /p}'
}

_branch_or_top() {
   if [ -n "$1" ] ; then
      printf %s "$1"
   else
      git branch \
         | grep ' stockpile/item-' \
         | tail -n 1 \
         | sed -e 's/^ *//;s/ *$//'
   fi
}

command_get() {
   local initial_branch="$(git rev-parse --abbrev-ref HEAD)"
   local initial_commit="$(git rev-parse              HEAD)"

   local post_branch="$(_branch_or_top "${1:-""}")"
   [ -n "$post_branch" ] || die 'no branch to get data from...'
   printf '<%s>\n' "$post_branch"

   git checkout "$post_branch"
   git rebase "$initial_branch"
   git checkout "$initial_branch"
   git merge --ff-only "$post_branch"
   git branch -d "$post_branch"
   git diff "$initial_commit" --name-only
}

command_show() {
   local branch="$(_branch_or_top "${1:-""}")"
   git diff "$branch^..$branch"
}

main() {
   [ $# -gt 0 ] || die "$0 cmd ... where cmd is add|get|list"

   command="$1"
   shift
   case "$command" in
      (add)
         command_add "$@"
         ;;
      (get)
         command_get "$@"
         ;;
      (list)
         command_list "$@"
         ;;
      (show)
         command_show "$@"
         ;;
      (*)
         die "unknown command <$command>"
         ;;
   esac

   return 0
}

main "$@"
