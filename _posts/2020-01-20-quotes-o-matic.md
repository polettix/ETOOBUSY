---
title: Quotes-O-Matic
type: post
tags: [ Mojolicious, perl, web, server ]
comment: true
date: 2020-01-20 08:00:00 +0100
published: false
---

**TL;DR**

> Serving interesting quotes through a simple [Mojolicious::Lite][]
> application is not difficult, enjoy [Quotes-O-Matic][qom-gitlab].

Our journey to transform a thread of tweets into a simple web page providing
random wisdom (which we started with post [Scrape a Thread of Tweets][] a
few days ago) is coming to an end, because we're now adding an important
piece to the puzzle:

<script src="https://gitlab.com/polettix/notechs/snippets/1931468.js"></script>

In case [GitLab][] is giving issues, take a look at the [local version][].

The code pretty much explain itself. We're relying upon an input file in
JSON format (named `quotes.json`, line 12) which we hunt for either in the
current directory, or in the program's directory (line 45).

The internal structure of the file is the same we described before in the
previous post about [jq magic][jq-magic]. Line 41 does the heavylifting of
reading the whole contents of the file (via `slurp`) and turn that into an
anonymous has (calling `j` on the JSON text).

Selection of a random quote is an old trick in [Perl][] (line 34): generate
a random number between 0 (inclusive) and the number of items in an array
(exclusive) and use that as an index inside the array itself: it will be
turned into an integer and used to extract one item.

The handler for the only supported endpoint can be understood reading
through the [Mojolicious tutorial][Mojolicious::Lite].

## See you soon!

Nothing more to add... apart wishing you happy hacking!

[Mojolicious::Lite]: https://metacpan.org/pod/distribution/Mojolicious/lib/Mojolicious/Guides/Tutorial.pod
[qom-gitlab]: https://gitlab.com/polettix/notechs/snippets/1931468
[Scrape a Thread of Tweets]: {{ '/2020/01/14/scrape-tweets-thread' | prepend: site.baseurl | prepend: site.url }}
[local version]: {{ '/assets/code/quotes-o-matic.pl' | prepend: site.baseurl | prepend: site.url }}
[GitLab]: https://www.gitlab.com/
[jq-magic]: {{ '/2020/01/19/jq-magic' | prepend: site.baseurl | prepend: site.url }}
[Perl]: https://www.perl.org/
