---
title: 'A parser for Ordeal::Model'
type: post
tags: [ perl, coding, parsing ]
comment: true
date: 2020-05-21 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Where I look back at a parser I wrote some time ago.

In previous post [Global string matching quirks][] I anticipated that I
would be looking into [Ordeal::Model::Parser][]. Here we come.

**NOTE**: I apologize with the fine folks at [Perl Weekly][] for all the
sea of boredom that they endure in looking through my posts. Sorry 😅


# A parser?

[Ordeal::Model][] allows you to build moderately complex *expressions*
to describe what kind of random draw you need. For example, the
following expression:

```text
die@1 * {3,4..5,6}
```

will roll a *random amount of dice* (between 3 and 6 dice) and give you
the result, while the following:

```text
(food + games)@2
```

will make a deck with both `food` and `games` and take two out of it. If
you are curious, you can take a look at section [EXPRESS YOURSELF][] in
the [Tutorial][].

We have an expression according to a grammar, hence we need a parser.

# A coded parser?

There are a few ways to translate a grammar into code, where *direct
translation* might not be the most obvious or maintainable one. I guess
the best you can do if you have to implement a parser for a reasonably
complicated grammar is to look into [Marpa::R2][] or read just about
anything that [Jeffrey Kegler][] wrote on the topic.

But.

In this case we have a very small grammar, without particular quirks...
so why not solve it all in a nicecly packed [Perl][] module? So yes, a
coded parser.

# Before you go on...

... you should be aware that [Mark Jason Dominus][] wrote about doing
this in a much better and cleaner way in [Higher Order Perl][]. I took
inspiration from there for what I did here, although I adapted it to my
needs. If you want, you can also [download the book][] (including the
individual chapter on Parsing).

If you continue to read from this series... it's now entirely upon you!

# The whole series

Want to look at the other parts of this series? Here's a list of them:

- [Global string matching quirks][] is not strictly in the series, but
  it's our first quest in [Ordeal::Model::Parser][] and it's possibly
  the one giving a one single useful advice!
- [A parser for Ordeal::Model][] is where the series start, introducing
  the motivations for the parser package.
- [Ordeal::Model::Parser: grammar][] introduces the grammar.
- [Ordeal::Model::Parser: entry point][] discusses the package's main
  entry point `PARSE`, which acts as a thin wrapper around
  `_expression`.

[Ordeal::Model::Parser: entry point]: {{ '/2020/05/23/omd-entry-point' | prepend: site.baseurl }}
[Ordeal::Model::Parser: grammar]: {{ '/2020/05/22/omd-grammar' | prepend: site.baseurl }}
[A parser for Ordeal::Model]: {{ '/2020/05/21/a-parser-for-ordeal-model' | prepend: site.baseurl }}
[Global string matching quirks]: {{ '/2020/05/20/global-string-matching' | prepend: site.baseurl }}
[Perl]: https://www.perl.org/
[Perl Weekly]: https://perlweekly.com/
[Ordeal::Model]: https://metacpan.org/pod/Ordeal::Model
[Ordeal::Model::Parser]: https://metacpan.org/pod/Ordeal::Model::Parser
[EXPRESS YOURSELF]: https://metacpan.org/pod/distribution/Ordeal-Model/lib/Ordeal/Model/Tutorial.pod#EXPRESS-YOURSELF
[Tutorial]: https://metacpan.org/pod/distribution/Ordeal-Model/lib/Ordeal/Model/Tutorial.pod
[Marpa::R2]: https://metacpan.org/pod/Marpa::R2
[Jeffrey Kegler]: https://jeffreykegler.github.io/personal/
[Mark Jason Dominus]: https://blog.plover.com/
[Higher Order Perl]: https://hop.perl.plover.com/
[download the book]: https://hop.perl.plover.com/book/
