---
title: 'Ordeal::Model::Parser: entry point'
type: post
tags: [ perl, coding, parsing ]
comment: true
date: 2020-05-23 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Where we start to look at the code for [Ordeal::Model::Parser][].

For *stability* of these blog posts, we will take a look at [the code as
in release 0.003][OMP].

Let's start with [PARSE][]:

```perl
 1 sub PARSE ($text) {
 2    state $expression = _expression();
 3    my $ast = $expression->(\$text);
 4    my $pos = pos $text;
 5    my ($blanks, $rest) = substr($text, $pos) =~ m{\A (\s*) (.*) }mxs;
 6    if (length $rest) {
 7       $pos += length($blanks // '');
 8       my $prest = $rest;
 9       $prest = length($rest) > SHOW_CHARS
10          ? (substr($rest, 0, SHOW_CHARS - length ELLIPSIS) . ELLIPSIS)
11          : $rest;
12       ouch 400, "unknown sequence starting at $pos '$prest'", $rest;
13    }
14    return $ast;
15 }
```

It is actually just a wrapper around `_expression()`, or better around
the function that is *provided* by `_expression()`. We just take care to
verify that the input string parses correctly and does not contain
characters we cannot include in the parsing.

To do this, we first run the parsing itself (line 3), then take a look
at where we ended up (line 4) and check that there is nothing left,
apart some blank spaces (lines 5 and test in line 6).

The function returns whatever was returned from the call in line 3; as
the name says, we're expecting this to be an [Abstract Syntax Tree][]
(or *AST*), i.e. a data structure modeled after the specific expression
that was parsed. This is instrumental to later *evaluate* the
expression, because it will mean that we will *traverse* the AST to get
a value from it.

So... the really interesting stuff seems to lie inside `_expression()`,
which provides us with the *real* entry point. Stay tuned!

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
[OMP]: https://github.com/polettix/Ordeal-Model/blob/0.003/lib/Ordeal/Model/Parser.pm
[PARSE]:https://github.com/polettix/Ordeal-Model/blob/0.003/lib/Ordeal/Model/Parser.pm#L20
[Abstract Syntax Tree]: https://en.wikipedia.org/wiki/Abstract_syntax_tree
[Ordeal::Model]: https://metacpan.org/pod/Ordeal::Model
