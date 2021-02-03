---
title: 'Ordeal::Model::Parser: parsing generics'
type: post
tags: [ perl, coding, parsing, 'Ordeal::Model' ]
series: 'Ordeal::Model'
comment: true
date: 2020-05-24 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Some generic parsing facilities, just for starters.

Before delving into transforming the grammar described in
[Ordeal::Model::Parser: grammar] into code, it's useful to introduce a
few *generic* parsing utilities that allow us to facilitate dealing with
alternations (i.e. the `|` character in the grammar), optional multiple
instances (i.e. the start `*` operator), etc. etc.

# The standardized parsing function interface

Functions instrumental to parsing all share the same interface:

```perl
sub parsing_function ($reference_to_text) {
    ...;
    return if $not_successful;
    return \@array_of_collected_stuff;
}
```

i.e. they accept a single parameter, that is a reference to the text to
be parsed. This parameter is usually abbreviated as `$rtext` in the
functions.

The return value is supposed to be `undef` if the parsing is
unsuccessful, otherwise a reference to an array with the *parsed stuff*
inside (whatever this means for the specific parsing stage).

The generic functions described below and in the next post will usually
be *factory functions* that return something compliant with the
interface above.

# Why passing a reference to the text?

To avoid copying text around, it's useful to always refer to the same
string all over, this is why. This gives us the added benefit of
avoiding chopping text from the input as we go on (which would mean more
string copying!), because each string in [Perl][] comes with a `pos()`
counter that helps tracking the position of regular expressions matching
in some specific conditions (that we are going to meet!).

This also means that all operations on the text will be performed on
`$$rtext` because - well - it's where the text lies.

# Verbatim, exact text

One of the needs in a grammar is to be able and match *verbatim text*
exactly. The following *factory function* takes the text we want to
match, and provides us a parser that does exactly this:

```perl
 1 sub __exact ($what, @retval) {
 2    my $wlen = length $what;
 3    return sub ($rtext) {
 4       my $pos = pos($$rtext) // 0;
 5       return if length($$rtext) - $pos < $wlen;
 6       return if substr($$rtext, $pos, $wlen) ne $what;
 7       pos($$rtext) = $pos + $wlen;
 8       return [@retval];
 9    };
10 }
```

The code is enough boring and self-explicative: to match a text exactly,
we have to ensure that we have enough characters left to analyze (line
5), that it actually matches (line 6). If the match is successful, we
advance the `pos()` marker of the string (go on!) and return whatever we
wanted to emit in association to the text.

As an example, this function might be called like this:

```perl
my $exact_parser = __exact('@', 'shuffle');
```

This `$exact_parser` complies with the parsing signature described
above, and does this:

- if the next character to be parsed is `@` then it returns an anonymous
  array with the string `shuffle` as its only item;
- otherwise, it returns `undef`.

It is important to note one thing here: the returned function not only
does parsing in the sense of *validating* the input according to the
grammar, but also returns something associated to the parsed text. In
this way, it can contribute in the building of the Abstract Syntax Tree
that is, eventually, what we are interested into.


# Regular expressions

This *factory function* helps us match regular expressions:

```perl
 1 sub __regexper ($rx) {
 2    return sub ($rtext) {
 3       my (undef, $retval) = $$rtext =~ m{\G()$rx}cgmxs or return;
 4       return [$retval];
 5    };
 6 }
```

It's a *factory function*, so as expected it returns a function (line
2). It accepts a *regular expression* `$rx` as input, so the returned
function will be different depending on the input regular expression.

The function basically takes care to match the regular expression *from
the point where we arrived with the parsing*. This is indicated by the
usage of the `\G` anchor inside the regular expression, as well as the
use of the `/cg` modifiers when calling the match. It's basic [Perl][]
regular expression trickery!

If you're curious about why the `undef` and the empty capture group in
line 3, you can take a look at [Global string matching quirks][].

The return value is:

- `undef` in case the regular expression does not match,
- whatever the input regular expression wants captured otherwise. In
  this case, the returned value is wrapped inside an anonymous array, so
  that it can be `undef` itself but still be true to the caller.

Again, this return value can be considered as a *leaf* in the Abstract
Syntax Tree.

# White space

In our grammar, we neglected whitespaces, so we have to make sure to
ignore them too. Function `__ews` does exactly this:

```perl
sub __ews ($rtext) { return __ewsr()->($rtext) }
sub __ewsr { state $retval = __regexper(qr{\s+}) }
```

This shows the difference we talked about: `__ews` is something that
*does* parsing (note the signature), while `__ewsr` is something that
*returns* something that *does* the parsing (again, see how the result
from `__ewsr` is used inside `__ews`).

Note that we use `__regexper` to match the empty spaces, but the regular
expression we pass does *not* contain any capturing - this means that
we're simply discarding the spaces!


# Stay tuned!

In the next post, we will look into the first generic facilities that
*combine* parsers together, e.g. the *alternatiion* and the *star
operator*. Stay tuned!


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
[Ordeal::Model::Parser]: https://metacpan.org/pod/Ordeal::Model::Parser
[Perl]: https://www.perl.org/
[Ordeal::Model]: https://metacpan.org/pod/Ordeal::Model
