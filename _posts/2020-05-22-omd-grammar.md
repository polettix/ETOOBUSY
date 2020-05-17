---
title: 'Ordeal::Model::Parser: grammar'
type: post
tags: [ perl, coding, parsing ]
comment: true
date: 2020-05-22 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Here you find the grammar for [Ordeal::Model::Parser][]. Hopefully.

I didn't write the grammar anywhere for documentation purposes - my bad
actually, so let's pay this *technical debt* now. Ehr yes... by *reverse
engineering* the code 😅

The entry point in the grammar is `expression`:

```text
expression: addend ( addop addend )*
addend: ( positive_int multop )* atom ( multop positive_int )*
atom: ( identifier | sub_expression ) unaryop* 
sub_expression: '(' expression ')'

addop:  '-' | '+'
multop: '*' | 'x'
unaryop: shuffler | simple_slicer | slicer | sorter
shuffler: '@'
simple_slicer: int
slicer: '[' int_item_list ']'
sorter: '!'

int: simple_int | random_int
simple_int: /0|-?[1-9][0-9]*/
random_int: '{' int_item_list '}'

int_item_list: int_item ( ',' int_item )* (',')?
int_item: int_simple_range | int_range | int
int_simple_range: '#' positive_int
int_range: int '..' int

identifier: token | quoted_string
token: /[a-zA-Z][a-zA-Z0-9_]*/
quoted_string: /"([^\\"]|\\.)"/

positive_int: ...
```

I hope I didn't get the symbols wrong:

- whitespacey stuff is not explicitly indicated to make stuff more
  readable
- quoted stuff is just what appears inside
- stuff between slashes are regular expressions (Backus and Naur will
  hopefully forgive me)
- the `|` character separates alternatives
- the `*` character means "zero or more of this"
- the '?' character means "zero or one of this"
- parentheses group stuff
- stuff in a sequence must appear in that sequence
- a `positive_int` is just like an `int` where all actual integers
  inside are constrained to be strictly positive (it could be expanded
  in the grammar but it would be more boring than it already is!)

As anticipated, not too much of a grammar!

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

[Ordeal::Model::Parser: parsing generics, 2]: {{ '/2020/05/25/omd-parsing-generics-2' | prepend: site.baseurl }}
[Ordeal::Model::Parser: parsing generics]: {{ '/2020/05/24/omd-parsing-generics' | prepend: site.baseurl }}
[Ordeal::Model::Parser: entry point]: {{ '/2020/05/23/omd-entry-point' | prepend: site.baseurl }}
[Ordeal::Model::Parser: grammar]: {{ '/2020/05/22/omd-grammar' | prepend: site.baseurl }}
[A parser for Ordeal::Model]: {{ '/2020/05/21/a-parser-for-ordeal-model' | prepend: site.baseurl }}
[Global string matching quirks]: {{ '/2020/05/20/global-string-matching' | prepend: site.baseurl }}
[Ordeal::Model::Parser]: https://metacpan.org/pod/Ordeal::Model::Parser
