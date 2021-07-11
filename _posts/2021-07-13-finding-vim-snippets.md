---
title: Finding Vim snippets in Bash
type: post
tags: [ vim, snippet, bash ]
comment: true
date: 2021-07-13 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A little [Bash][] program (with completions) to show [Vim][]
> [snippets][].

I've started using [snippets][] for [Vim][] lately, and one thing that
sometimes drives me crazy is that I don't remember the *clever*
(**AHEM** 🙄) name I gave to some of them.

This usually got me into hunting for the right file, listing all
snippets and then using it. Veeeery efficient.

So enter `snippets`, a little [Bash][] program to show them on the
command line:

```bash
#!/bin/bash

_snippets_completion() {
   local alts=''
   if [ "$COMP_CWORD" -eq 1 ] ; then
      alts=$(ls ~/.vim/snippets | sed -e 's/\.snippets//')
   elif [ "$COMP_CWORD" -eq 2 ] ; then
      alts=$(grep -Po '^snippet *\K.*' ~/.vim/snippets/"${COMP_WORDS[1]}.snippets")
   fi
   COMPREPLY=($(compgen -W "$alts" "${COMP_WORDS["$COMP_CWORD"]}"))
}

if [[ "${BASH_SOURCE[0]}" = "${0}" ]] ; then
   if [ $# -eq 0 ] ; then
      ls ~/.vim/snippets | sed -e 's/\.snippets//'
   elif [ $# -eq 1 ] ; then
      grep -Po '^snippet *\K.*' ~/.vim/snippets/"$1.snippets"
   else
      cat ~/.vim/snippets/"$1".snippets \
         | sed -ne "/^snippet $2/,/^snippet/p" \
         | sed -e '${/^snippet /d}'
   fi
else
   complete -F _snippets_completion snippets
fi
```

Also [here][gls].

When called without parameters, it shows which file types have snippets
associated (hunting them in `~/.vim/snippets/`):

```
$ snippets 
markdown
perl
raku
```

When called with one parameters (that is, a file type), it shows all
snippets available for that type:

```
$ snippets perl
aoc
llib
plb
```

Last, when called with two parameters, it prints the specific snippet in
the specific file type:

```
$ snippets perl plb
snippet plb
	#!/usr/bin/env perl
	use v5.24;
	use warnings;
	use experimental 'signatures';
	no warnings 'experimental::signatures';
```

The thing that makes it much more useful, though, is the support for
[Bash][] auto-completion, as the program also doubles down as a script
that can be *sourced*, e.g. in `~/.bashrc`:

```
if [ -x ~/bin/snippets ] ; then
    . ~/bin/snippets
fi
```

This allows using the tab to make [Bash][] do the hard work:

<script id="asciicast-424649" src="https://asciinema.org/a/424649.js" async></script>

*(Yes, the little pauses are me doing `TAB - TAB` on the keyboard!)*

Want to know more about [Bash][] autocomplete? I read this tutorial:
[How to create a Bash completion script][tutorial] and found it useful
(although, I have to admit, I skimmed most of the comment in search for
the code examples).

Nifty!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Vim]: https://www.vim.org/
[snippets]: https://github.com/honza/vim-snippets
[Bash]: https://www.gnu.org/software/bash/
[gls]: https://gitlab.com/polettix/notechs/-/snippets/2147310
[tutorial]: https://opensource.com/article/18/3/creating-bash-completion-script
