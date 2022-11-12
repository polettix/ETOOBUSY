---
title: Parsing toolkit in cglib
type: post
tags: [ algorithm, parsing, perl ]
comment: true
date: 2020-07-11 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> The parsing functions from [A parser for Ordeal::Model][] went into
> [cglib][], my library for [CodinGame][].

This pretty much says it all - the code is available at [Parser.pm][],
while the documentation can be found at [Parser.pod][].

The function formerly known as `__starer` has been evolved into
[`pf_repeated`][pf_repeated], which now accepts also a maximum number of
matches. This allows implementing `*` (the default), `+` (already
available by setting the minimum number of matches to 1) as well as `?`
(set minimum to 0 and maximum to 1) and the more generic `{min, max}`
(just pass the values).

As always, the implementation strives for compactness and is not really
meant for long-term maintenable code. But it should come handy in low to
low-medium projects with some parsing needs.

[A parser for Ordeal::Model]: {{ '/2020/05/21/a-parser-for-ordeal-model' | prepend: site.baseurl }}
[#algorithm]: {{ '/tagged/#algorithm' | prepend: site.baseurl | prepend: site.url }}
[cglib]: https://github.com/polettix/cglib-perl
[CodinGame]: https://www.codingame.com/
[Parser.pm]: https://github.com/polettix/cglib-perl/blob/master/Parsing.pm
[Parser.pod]: https://github.com/polettix/cglib-perl/blob/master/Parsing.pod
[pf_repeated]: https://github.com/polettix/cglib-perl/blob/master/Parsing.pm#L60
