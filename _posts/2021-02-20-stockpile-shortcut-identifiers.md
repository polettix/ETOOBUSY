---
title: Stockpile of posts gets shortcuts to items
type: post
tags: [ blog, shell ]
comment: true
date: 2021-02-20 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Another enhancement to [stockpile.sh][] - shorter identifiers!

In previous post [Stockpile of posts gets dates in listing][] we took a
look at the new listing capabilities of [stockpile.sh][], in particular
the addiition of the *anticipated* date of publishing and also an
initial numeric identifier gently provided by `nl`.

One of the things that was annoying me in using that program was that
item-specific commands like `show` or `xget` need the full name of the
branch, which is long.

OK, there's a quick mouse copy-and-paste, **but** when you run `show`
and *then* `xget` it can become cumbersome. It's much easier to use a
shortcut progressive identifier, isn't it?

For this reason, commands that operate on specific items (i.e. `get`,
`show`, and `xget`) can take either a full item identifier (which is
none other than the name of the branch the item lives in) *or* the
numeric identifier that is gently provided by the `list` command.

The *magic* is done by the following function, which can take either an
empty string (which will "pass" unaltered), or a branch identifier
(which will "pass" unaltered), or a numeric short identifier (which will
transform into a branch name):

```shell
_resolve() {
   local in="${1:-""}"
   [ -n "$in" ] || return 0
   if [ "${in%%/*}" = 'stockpile' ] ; then
      printf %s "$in"
   else
      local tab="$(printf '\t')"
      local out="$(command_list | grep "^[ $tab]\\+$in[ $tab]" | awk '{print $2}')"
      if [ -n "$out" ] ; then
         printf %s "$out"
      else
         printf %s "$in"
      fi
   fi
}
```

I'm not entirely sure of whether I should complain loudly if the input
is *neither* a branch name *nor* a shortcut identifier for a post... but
there should be little harm anyway, as some other element down the chain
will complain.

Or make a terrible mess.


[stockpile.sh]: https://github.com/polettix/ETOOBUSY/blob/master/stockpile.sh
[Stockpile of posts gets dates in listing]: {{ '/2021/02/19/stockpile-list-with-dates/' | prepend: site.baseurl }}
