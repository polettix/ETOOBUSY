---
title: 'A pull request for Path::Tiny'
type: post
tags: [ perl, coding ]
comment: true
date: 2021-10-02 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I proposed a [pull request][] for [Path::Tiny][].

Some days ago I was using [Path::Tiny][] ([remember it][]?) and at a
certain point I had an object pointing to a directory, where I wanted to
save a file.

`push` DIVERSION

> Being a paranoid, I'm always thinking about apocalyptic scenarios
> where saving the file is not atomic and something might go wrong
> mid-way, leaving me with a half-baked file. (Think about laundry-list
> level of data relevance to anyone's life, of course).
>
> The idiom I use in this case is:
>
> - save the data in a temporary file *in the same filesystem as the
>   target*;
> - if saving *and closing* the file is fine, use [rename][] to move the
>   file to destination.
>
> If we are on the right operating system and with the right filesystem,
> the second operation is atomic, which means:
>
> - either saving the file goes wrong, in which case we are left with a
>   half-baked *temporary file* and no target file at all, which is
>   fine;
> - or saving the file goes fine, but renaming it does not, in which
>   case we have no target file again, which is fine;
> - or everything goes fine, and we have our target file.
>
> That is, either the target file is missing or it is there, there's no
> midway.

`pop`

OK, so I'm with my [Path::Tiny][] directory object, and first of all I
want to *create a temporary file in that directory*. The module has a
method for it, namely `tempfile`:

```perl
my $tempfile = Path::Tiny->tempfile(...);
```

How cute, a *class method*... a tiny, little *class method*... well
*there MUST be an instance method too, right?*

**RIGHT?!?**

Well... no. There is [issue #115][] though, which deals exactly with
this and has the following refreshing comment from [Path::Tiny][]'s
author and maintainer:

> Interesting idea. It would really just mean setting the "DIR" option
> to the current path (unless a DIR option is provided). I'm open to a
> pull request as long as it includes tests, code and documentation.

So here I am, one day into [Hacktoberfest][], to propose [a pull request
to address this][pull request].

To be completely honest, it *does not* do what they are asking. I mean,
I thought about the *unless a DIR option is provided* part in the
comment, and in my (very) humble opinion in that case the object should
still win over the option. If you want the option... then use the class
method, it's just more readable. Of course this is *my* take on this,
and it can be changed quite easily.

Help me to cross as many fingers as possible 🤞🤞🤞 and... stay safe!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[remember it]: {{ '/2020/06/10/path-tiny' | prepend: site.baseurl }}
[Path::Tiny]: https://metacpan.org/pod/Path::Tiny
[rename]: https://perldoc.perl.org/functions/rename
[issue #115]: https://github.com/dagolden/Path-Tiny/issues/115
[pull request]: https://github.com/dagolden/Path-Tiny/pull/242
[Hacktoberfest]: https://hacktoberfest.digitalocean.com/
