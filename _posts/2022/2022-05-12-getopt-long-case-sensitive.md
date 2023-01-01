---
title: 'Getopt::Long long options can be case-sensitive'
type: post
tags: [  ]
comment: true
date: 2022-05-12 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [Getopt::Long][] can behave case-sensitively too.

In a previous post ([Getopt::Long long options are case-insensitive][])
I underlined how *long* options supported by [Getopt::Long][] are
handled case-insensitively by default.

[Αριστοτέλης Παγκαλτζής][giant] [chimed in][] ([again][] after one year
and and a few days) to point out that this is not *hard and fast* and
there's a different way:

![Aristotle on Getopt::Long]({{ '/assets/images/aristotle-getopt-long.png' | prepend: site.baseurl }})

Incidentally, this made me discover that, *by default*, abbreviations
are put in there out of the box. TIL FTW!

Stay safe folks, stay safe...

[Perl]: https://www.perl.org/
[Getopt::Long long options are case-insensitive]: {{ '/2022/05/08/getopt-long-case-insensitive/' | prepend: site.baseurl }}
[Getopt::Long]: https://metacpan.org/pod/Getopt::Long
[giant]: http://plasmasturm.org/about/#me
[chimed in]: https://twitter.com/apag/status/1524319552322129921?s=20&t=5Uc9yKnmvf6hGhLj3rAzLQ
[again]: {{ '/2021/05/08/perlrun-no-butterfly/' | prepend: site.baseurl }}
