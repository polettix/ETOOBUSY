---
title: 'Ordeal::Model::Parser: parsing'
type: post
tags: [ perl, coding, parsing, series:Ordeal::Model ]
comment: true
date: 2020-05-26 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Where we take a look at the *domain* parsing function in
> [Ordeal::Model::Parser][].

As before, we will refer to the code for [version 0.003][]. We will not
get into the details for everything, just take a look at some of the
functions - the other ones are implemented pretty much in the same way.

# Behind-the-scenes entry point

The de-facto entry point is `_expression`:

```perl
 1 sub _expression {
 2    state $r = sub ($rtext) {
 3       state $addend = _addend();
 4       state $seq = __sequencer(
 5          $addend,
 6          __starer(__sequencer(__regexper(qr{([-+])}), $addend)),
 7       );
 8       state $name_for = {'+' => 'sum', '-' => 'subtract'};
 9       my $match = $seq->($rtext) or return;
10       my ($retval, $transformations) = $match->@*;
11       for my $t ($transformations->@*) {
12          my ($op, $addend) = $t->@*;
13          $retval = [$name_for->{"$op->@*"}, $retval, $addend];
14       }
15       return $retval;
16    };
17 }
```

As most (if not all!) functions in this parser, this factory is
implemented to always return the same function, by memoizing the parsing
workhorse as a `state` variable.

According to the grammar, an `expression` is:

```text
expression: addend ( addop addend )*
addop: '-' | '+'
```

and lines 3 to 7 implement pretty much this. For simplicity, the `addop`
is implemented as a regular expression to get both characters with a
single parsing function.

Lines 8 to 15 deal with the building of the Abstract Syntax Tree. Both
operations are supposed to be associative on the left, so we start from
the left-most element (that is the `$addend` in line 5) and for each
item collected in the `*` sequence we build a new node based on the
result of the previous iteration, the specific operation in that item
and the associated addend. Operations names are changed on the fly to
use a more verbose version.

In other words, a sequance like this

```text
A - B + C - D
```

is turned into this data structure (sort of, the terminals are shown as
play strings but are something different actually):

```text
[
    "subtract",
    [
        "sum",
        [
            "subtract",
            "A",
            "B"
        ],
        "C"
    ],
    "D"
]
```

You can see how easy is to evaluate this: for each level, get calculate
the two operands (possibly in a recursive way), then apply the specific
operation.

# The addend

From the grammar:

```text
addend: ( positive_int multop )* atom ( multop positive_int )*
multop: '*' | 'x'
```

The implementation is pretty much it:

```perl
 1 sub _addend {
 2    state $r = sub ($rtext) {
 3       state $op = __regexper(qr{([*x])});
 4       state $seq = __sequencer(
 5          __starer(__sequencer(_positive_int(), $op)),
 6          _atom(),
 7          __starer(__sequencer($op, _positive_int())),
 8       );
 9       my $match = $seq->($rtext) or return;
10       my ($pre, $retval, $post) = $match->@*;
11       $retval = ___mult($retval, reverse($_->@*)) for reverse($pre->@*);
12       $retval = ___mult($retval,        ($_->@*)) for        ($post->@*);
13       return $retval;
14    }
15 }
```

The main workhorse is a sequence of a star expression (line 5), an
`atom` (line 6), and another star expression (line 7). After the match
(line 9) we find the Abstract Syntax Tree building.

Note that operations are applied from the `atom` outwards, with
preference for the prefixes. Going outwards means that elements *before*
the `atom` enjoy a `reverse`. The `___mult` is a helper that builds a
node for the AST.

# The atom

From the grammar we have:

```text
atom: ( identifier | sub_expression ) unaryop* 
sub_expression: '(' expression ')'
unaryop: shuffler | simple_slicer | slicer | sorter
...
```

In the implementation, for a bit of added clarity it has been
implemented like follows:

```text
atom: atom_base atom_unary* 
atom_base: identifier | sub_expression
sub_expression: '(' expression ')'
atom_unary: shuffler | simple_slicer | slicer | sorter
...
```

In code:

```perl
 1 sub _atom {
 2    state $base = _atom_base();
 3    state $unaries = __starer(_atom_unary());
 4    state $retval = sub ($rtext) {
 5       my $retval = $base->($rtext) or return;
 6       for my $unary ($unaries->($rtext)->@*) {
 7          my ($op, @rest) = $unary->@*;
 8          $retval = [$op, $retval, @rest];
 9       }
10       return $retval;
11    };
12 }
```

Lines 2 and 3 build the two pieces for `atom_base` and `atom_unary` in
the grammar and assemble them in a function (lines 4 to 11) that does
the matching attempt (line 5) and, when successful, builds the Abstract
Syntax Tree section for it. The logic is pretty much the same we saw
before in `expression`, only with different pieces that have a higher
priority of evaluation (the unary operators).

The code for `atom_base` completes the thing:

```perl
 1 sub _atom_base {
 2    state $sub_expression = sub ($rtext) {
 3       state $seq = __sequencer('(', _expression(), ')');
 4       my $match = $seq->($rtext) or return;
 5       return $match->[1];
 6    };
 7    state $retval = __alternator(
 8       _identifier(),
 9       $sub_expression,
10    );
11 }
```

Again, pretty much a literal translation, with a sub-expression (line 2
to 6) and an identifier that are combined with an alternation operation
(lines 7 through 10).

Just for curiosity, let's take a look at one of the unary operators:

```perl
sub _shuffler { state $r = __exact('@', 'shuffle') }
```

It's just an exact match for the character `@`, which gets eventually
returned as the string `shuffle`. Nothing terribly exciting.


# This is about it

As anticipated, we will not go through each and every function, the
examples above should provide a precise idea of the philosophy of the
module:

- every parsing bit is a reference to a sub that complies with a
  specific interface (text input as reference to a scalar, output an
  anonymous array or `undef`)
- generic functions are leveraged to combine bits according to the
  *usual* rules for a grammar (e.g. `*`, `|`, etc)
- the grammar is translated into code first assembling the different
  parsers, then operating on the return value to give the resulting
  Abstract Syntax Tree the *right shape*, so that it can be easily used
  for evaluation at a later stage.

At this point... it's all folks!

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
[Ordeal::Model]: https://metacpan.org/pod/Ordeal::Model
[Ordeal::Model::Parser]: https://metacpan.org/pod/Ordeal::Model::Parser
[version 0.003]: https://github.com/polettix/Ordeal-Model/blob/0.003/lib/Ordeal/Model/Parser.pm
