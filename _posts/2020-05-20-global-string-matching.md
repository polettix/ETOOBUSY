---
title: Global string matching quirks
type: post
tags: [ perl, coding, regex, Ordeal::Model ]
series: Ordeal::Model
comment: true
date: 2020-05-20 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Where I re-learn a trick about the `/g` modifier in [Perl][] patterm
> matching.

While taking a look at [Ordeal::Model::Parser][] (which will hopefully
be the topic for some other post), I stumbled upon the following
function definition:

```perl
 1 sub __regexper ($rx) {
 2    return sub ($rtext) {
 3       my (undef, $retval) = $$rtext =~ m{\G()$rx}cgmxs or return;
 4       return [$retval];
 5    };
 6 }
```

It returns a subroutine (line 2) that is supposed to accept a *reference
to a scalar* variable holding the text to match, applies a pre-defined
regular expression `$rx` on it and returns what was captured, if
anything, inside an anonymous array.

While I understand the general philosophy (like *match `or return`*,
giving back stuff in an anonymous array to avoid confusing the receiver,
etc.), I could not understand the regular expression evaluation line:

```perl
 my (undef, $retval) = $$rtext =~ m{\G()$rx}cgmxs or return;
 ##  ^^^^^                            ^^
 ##       \_wow look at this stuff!!_/  
```

I'm deliberatingly inserting an *empty capturing group* whose result I'm
eventually tossing away (via the `undef` in the list on the left-hand
side). Why?

(I think my past self was surely thinking of me in this Covid-19 madness
and graciously peppering mysteries in the code!)

The answer lies in the kind of regular expressions that are allowed as
inputs to `__regexper`, i.e. *both* regular expressions that are meant
to *capture* stuff, as well as others that are there to just match
something (e.g. for getting rid of white space).

Let's consider the simpler alternative without the extra stuff:

```perl
my ($retval) = $$rtext =~ m{\G$rx}cgmxs or return;
```

When `$rx` does have a capturing group, it works as the other one. For
example, if the regular expression is `qr{([-+])}` (i.e. capture either
of the minus or the plus characters, once), the evaluation is like the
following:

```perl
my ($retval) = $$rtext =~ m{\G([-+])}cgmxs or return;
```

and works as expected: if the character is missing then `undef` is
returned, otherwise the following line:

```perl
return [$retval];
```

will return the character as the lone item inside an anonymous array.

On the other hand, what happens when I *do not* want to capture stuff?
As an example, let's consider the regular expression `qr{\s+}` to ignore
white spaces, this would mean having:

```perl
my ($retval) = $$rtext =~ m{\G\s+}cgmxs or return;
return [$retval];
```

When there *is* white space, I would expect this to return an anonymous
array containing `undef` but... I actually get all the white spaces
inside!

To understand this, let's do a `perldoc -f m` and read:

> The "/g" modifier specifies global pattern matching--that is, matching
> as many times as possible within the string. How it behaves depends on
> the context. In list context, it returns a list of the substrings
> matched by any capturing parentheses in the regular expression. If
> there are no parentheses, it returns a list of all the matched
> strings, as if there were parentheses around the whole pattern.

There we are! No parentheses means a whole pair of parentheses around
the whole pattern! On the other hand, in the original code we would
have:

```perl
my (undef, $retval) = $$rtext =~ m{\G()\s+}cgmxs or return;
return [$retval];
```

which *does have* a pair of (empty) parentheses, so `$retval` ends up
being `undef` as expected.

I. Don't. Want. To. Capture. This. Stuff.

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
- [Ordeal::Model::Parser: parsing generics][] deals with the starting
  generic helpers to build parsing functions.
- [Ordeal::Model::Parser: parsing generics, 2][] describes the *hard
  stuff* like sequences, alternations, and the star operator.
- [Ordeal::Model::Parser: parsing][] gives an overview of the actual
  implementation of the grammar for [Ordeal::Model][].

[Ordeal::Model::Parser: parsing]: {{ '/2020/05/26/omd-parsing' | prepend: site.baseurl }}
[Ordeal::Model::Parser: parsing generics, 2]: {{ '/2020/05/25/omd-parsing-generics-2' | prepend: site.baseurl }}
[Ordeal::Model::Parser: parsing generics]: {{ '/2020/05/24/omd-parsing-generics' | prepend: site.baseurl }}
[Ordeal::Model::Parser: entry point]: {{ '/2020/05/23/omd-entry-point' | prepend: site.baseurl }}
[Ordeal::Model::Parser: grammar]: {{ '/2020/05/22/omd-grammar' | prepend: site.baseurl }}
[A parser for Ordeal::Model]: {{ '/2020/05/21/a-parser-for-ordeal-model' | prepend: site.baseurl }}
[Global string matching quirks]: {{ '/2020/05/20/global-string-matching' | prepend: site.baseurl }}
[Perl]: https://www.perl.org/
[Ordeal::Model::Parser]: https://metacpan.org/pod/Ordeal::Model::Parser
[Ordeal::Model]: https://metacpan.org/pod/Ordeal::Model
