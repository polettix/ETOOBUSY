---
title: 'Ordeal::Model::Parser: parsing generics, 2'
type: post
tags: [ perl, coding, parsing ]
comment: true
date: 2020-05-25 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Additional generic parsing facilities, inspired by [Higher Order
> Perl][].

# Sequences

One of the basic constructs in implementing a grammar is to put
different pieces one after the other. This is what the following
*factory function* helps us doing, i.e. combine a list of parsers to
ensure that they are matched in the exact sequence that we provide:

```perl
 1 sub __sequencer (@items) {
 2    return sub ($rtext) {
 3       my $pos = pos $$rtext;
 4       my @retval;
 5       for my $item (@items) {
 6          my $ews = __ews($rtext);
 7          $item = __exact($item) unless ref $item;
 8          if (defined(my $piece = $item->($rtext))) {
 9             push @retval, $piece;
10          }
11          else { # fail
12             pos($$rtext) = $pos;
13             return;
14          }
15       }
16       return \@retval;
17    };
18 }
```

The `@items` are supposed to be valid parsers, i.e. compliant to the
signature:

```perl
sub some_parser ($rtext) { ...; return $success ? \@stuff : undef }
```

and they are actually called like this (line 8).

The implementation is somehow boring: we iterate through all items in
`@items`, in order, and bail out if any of them fails (line 11 to 14).

Note that we save the starting condition at the beginning, by means of
the `$pos` variable, initialized in line 3. When the parsing of the
sequence fails, we roll back to that position (line 12).

When successful, the return value is the sequence of the return values
of all pieces in the list. Hence, it complies with the expected
interface, and does not miss anything in the middle.

# Alternations

What would be a grammar without alternatives? Yes, we're talking about
the `|` here! We have a factory function for this:

```perl
 1 sub __alternator (@alternatives) {
 2    return sub ($rtext) {
 3       __ews($rtext);
 4       for my $alt (@alternatives) {
 5          next unless defined(my $retval = $alt->($rtext));
 6          return $retval;
 7       }
 8       return;
 9    };
10 }
```

The alternatives (which in the grammar would be separated by `|`) are
passed as the input list; they are supposed to be parsing functions
themselves, i.e. sticking to the signature we discussed before
(accepting a reference to a scalar only).

The generated function iterates through the provided alternatives (line
4), calling them until one of them succeeds or no more are available
(line 5).

If one of the alternatives is successful, its returned values is simply
returned by the alternation function (line 6); otherwise, nothing is
returned (line 8).

# The Star operator

Another useful element in a grammar is the possibility to have a certain
item appear a variable number of times, e.g. the `*` operator that means
*zero or more instances*. Here is our *factory* for it:

```perl
 1 sub __starer ($what, $min = 0) {
 2    return sub ($rtext) {
 3       my $pos = pos $$rtext;
 4       my @retval;
 5       my $local_min = $min;
 6       while ('possible') {
 7          __ews($rtext);
 8          defined(my $piece = $what->($rtext)) or last;
 9          push @retval, $piece;
10          if ($local_min > 0) {
11             --$local_min;
12          }
13          else {
14             $pos = pos $$rtext;
15          }
16       }
17       pos($$rtext) = $pos; # "undo" last try/tries
18       return if $local_min > 0; # failed to match at least $min
19       return \@retval;
20    };
21 }
```

The `$what` input argument is supposed to stick to the interface for a
*parser*, i.e. a reference to the scalar with the text as input, and a
reference to an array as successful output (or `undef` otherwise).

This implementation also allows setting a *minimum* number of instances;
as such, when providing e.g. 1 in this parameter, we can get the `+`
operator for free. It is also possible to set higher minimum values.

The iteration starting in line 6 is not defined a-priori, so any *true*
value is good. Line 7 gets rid of whitespaces.

Line 8 does the attempt to parse the next possible occurrence of what is
parsed by `$what`. If successful, then line 9 records the collected item
in `@retval` and, if possible, advances the marker for parsing (i.e. the
`pos()` of the string reference by `$rtext`). This is subject to the
fact of having collected a minimum number of items, as dictated by
`$min` (line 5 and then line 10 and 11).

Line 17 does some roll-back. This is necessary when the parsing didn't
reach the minimum number of items (in which case `$pos` is the same as
the beginning value, set in line 3); otherwise, `$pos` is updated to the
latest position (line 14) and line 17 becomes a no-op.

The return conditions/values in lines 18 and 19 are pretty self-evident;
in particular, successful matches return all the collected outcomes of
the successful calls to `$what`.

# Lists of stuff

The following *factory* function helps defining lists of things that are
optionally separated by a... separator (that is ditched).

```perl
 1 sub __lister ($what, $sep = undef) {
 2    $sep = __exact($sep) if defined($sep) && ! ref($sep);
 3    return sub ($rtext) {
 4       __ews($rtext);
 5       defined(my $base = $what->($rtext)) or return;
 6       my $rest = __starer(
 7          sub ($rtext) {
 8             if ($sep) {
 9                __ews($rtext);
10                $sep->($rtext) or return; # check & discard
11             }
12             __ews($rtext);
13             $what->($rtext);
14          }
15       )->($rtext);
16       $sep->($rtext) if $sep; # optional ending
17       unshift $rest->@*, $base;
18       return $rest;
19    };
20 }
```

It leverages many of the primitives that we saw so far:

- the input separator (if present) is transformed into a parser for an
  exact string if necessary (line 2);
- spaces are ditched (lines 4, 9, and 12);
- an initial parse for the first item is attempted at line 5, then the
  *rest* is parsed according to a star-operator application of the
  sequence of an optional separator and an item.

An optional final separator is allowed (line 16). On the way, separators
are ignored, and only items are collected: the `*` operator application
(lines 6 to 15) is applied to a sub-parser that only returns the values
from `$what`, that is the parser for our target items.

The return value from the star operator only needs to be integrated with
the very first parsed item (line 17) and then can be returned.


# Enough with generic constructs!

At this point, we have all we need for implementing our grammar... stay
tuned!

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
[Higher Order Perl]: https://hop.perl.plover.com/
[Ordeal::Model]: https://metacpan.org/pod/Ordeal::Model
