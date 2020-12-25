---
title: A gift from Abigail
type: post
tags: [ perl, regex, parsing ]
comment: true
date: 2020-12-25 18:39:59 +0100
mathjax: false
published: true
---

**TL;DR**

> An example is worth a thousands explanations.

In recent post [Trying Marpa][], I described how I decided to jump on the
shoulders of Giants to address the [19th day][] of [Advent of Code][].

That allowed me to overcome one of the drawbacks of having a small,
low-level library of functions for building parsers:

> So far, this has prevented me doing two things:
> 
> - learn *more* on what regular expressions have become in later years, and
> - learn *something* about [Marpa][] (well... release 2 at least).

After solving that day's challenge, I went through the [19th day specific
thread on Reddit][reddit-19] and noticed [a little, great
gift][abigail-reddit-19] by [\_\_Abigail\_\_][] (yes, *that* [Abigail][]):

```
/(?(DEFINE)
    (?<RULE_0>(?: (?&RULE_4) (?&RULE_1) (?&RULE_5)))
    (?<RULE_1>(?: (?&RULE_2) (?&RULE_3) )|(?: (?&RULE_3) (?&RULE_2)))
    (?<RULE_2>(?: (?&RULE_4) (?&RULE_4) )|(?: (?&RULE_5) (?&RULE_5)))
    (?<RULE_3>(?: (?&RULE_4) (?&RULE_5) )|(?: (?&RULE_5) (?&RULE_4)))
    (?<RULE_4>(?: a))
    (?<RULE_5>(?: b))
)^(?&RULE_0)$/x
```

So today I decided to unwrap the gift and do a further step to understand
*modern Perl regular expressions*.

Of course the constructs in the little gem above are all explained in the
[perlre][] documentation, but being able to relate the code above with a
specific grammar is invaluable:

```
RULE_0: RULE_4 RULE_1 RULE_5
RULE_1: RULE_2 RULE_3 | RULE_3 RULE_2
RULE_2: RULE_4 RULE_4 | RULE_5 RULE_5
RULE_3: RULE_4 RULE_5 | RULE_5 RULE_4
RULE_4: "a"
RULE_5: "b"
```

So I get this:

- the `(?(DEFINE) ... )` block gives us some *free space* that does no real
  matching but allows us put all our definitions, great!

- each rule is defined as a named one with the construct `(?<NAME_OF_RULE>(?
  ... ))`, fine!

- calling another subrule resembles the full formal way of calling [Perl][]
  functions with construct `(?&NAME_OF_RULE)`, awesome!

After all this `DEFINE`-ing, it's match time, so there's the call to
`^(&RULE_0)$` that basically asks to match the whole string against the
start rule.

Of course there's a lot more to learn. In particular, I'm not sure this is
the best tool for the job in case we actually want to do *something* with
the captures, like building a AST with some transformations, but it's still
interesting to have a quick example of how to use the recursive features of
[Perl][]'s regular expressions engine.

Thanks [Abigail][] 🤩

[Trying Marpa]: {{ '/2020/12/20/trying-marpa/' | prepend: site.baseurl }}
[Jeffrey Kegler]: http://www.jeffreykegler.com/
[19th day]: https://adventofcode.com/2020/day/19
[Advent of Code]: https://adventofcode.com/
[reddit-19]: https://www.reddit.com/r/adventofcode/comments/kg1mro/2020_day_19_solutions/
[__Abigail__]: https://www.reddit.com/user/__Abigail__/
[Abigail]: https://github.com/Abigail
[abigail-reddit-19]: https://www.reddit.com/r/adventofcode/comments/kg1mro/2020_day_19_solutions/ggcozs3?utm_source=share&utm_medium=web2x&context=3
[perlre]: https://perldoc.perl.org/perlre
[Perl]: https://www.perl.org/
[Marpa]: https://metacpan.org/pod/Marpa::R2
