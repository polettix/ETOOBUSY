---
title: 'New App::Easer release 2.006'
type: post
tags: [ perl, client, terminal ]
comment: true
date: 2023-01-09 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> There's a new release of [App::Easer][]: 2.006.

I forgot to cite in the `Changes` file, but this all thanks to these two
issues:

- [Suggested change in help message for "mandatory" and "optional"
  values][issue1]
- [Help message for Boolean option incorrectly indicates it takes a
  value][issue2]

Thanks to the first one, I also learned that *boolean options* in
[Getopt::Long][] do not necessarily need `!` - this is only needed in
case we want to be able to also *negate* the option.

Stay safe!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[App::Easer]: https://metacpan.org/pod/App::Easer
[issue1]: https://github.com/polettix/App-Easer/issues/4
[issue2]: https://github.com/polettix/App-Easer/issues/5
[Getopt::Long]: https://metacpan.org/pod/Getopt::Long
