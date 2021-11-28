---
title: 'Pod::Markdown and Pod::Markdown::Github for the win!'
type: post
tags: [ perl, markdown, pod ]
comment: true
date: 2021-08-24 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [Pod::Markdown][] and [Pod::Markdown::Github][] are two fine modules.

Which, of course, most of us will *usually* ignore, thanks to the
related command-line programs that allow us consuming their services
without fiddling with the internals.

As the name suggests, [pod2markdown][] converts our beloved *Plain Old
Documentation* (POD) into the [Markdown][] format. It's as easy as doing
this:

```shell
pod2markdown lib/My/Awesome/Module.pm README.md
```

But wait, there's more! The plain [pod2markdown][] uses indentation for
your code sections, so this:

```
whatever
you

   do
```

would be represented like this:

```
␠␠␠␠whatever
␠␠␠␠you
␠␠␠␠
␠␠␠␠␠␠␠do
```

where `␠` represents - well - a space character (ASCII 0x20).

If you prefer the code fences instead, you can opt for [pod2github][]
from the second module instead. Same usage approach, just a drop-in
replacement.

Aren't they cool, really?!?


[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Pod::Markdown]: https://metacpan.org/pod/Pod::Markdown
[Pod::Markdown::Github]: https://metacpan.org/pod/Pod::Markdown::Github
[Markdown]: http://daringfireball.net/projects/markdown/syntax
[pod2markdown]: https://metacpan.org/dist/Pod-Markdown/view/bin/pod2markdown
[pod2github]: https://metacpan.org/dist/Pod-Markdown-Github/view/bin/pod2github
