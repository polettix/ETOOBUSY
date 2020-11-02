---
title: Fantasy Name Generator - a grammar
type: post
tags: [ perl, parsing ]
comment: true
date: 2020-11-02 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I stumbled upon a grammar for a "system" for generating fantasy names.

Sifting through some of my links, I (re-)discovered an interesting blog:
[null program][]. Among a lot of stuff there, I was intrigued by
[Fantasy Name Generator: Request for Patterns][], from about *eleven*
years ago.

In a nutshell, the author re-created the [Fantasy Name Generator][] by
Samuel Stoddard at [RinkWorks][], implementing a parser for the
generator sequences and then using them to do the actual generator.

It's interesting that at the time the author was still using [Perl][]
and leveraged [Parse::RecDescent][] to use a grammar he came up with to
do the parsing. I don't know why, the result was *slooooowwwww*, maybe
due to a combination of an older version of the module and probably a
grammar that can be improved.

The code is online at [FantasyName.pm][], which is interesting for a few
reasons:

- [Parse::RecDescent][] allows to *pre-generate* a parser and save it as
  a module. This saves doing this over and over;
- I usually separate the *parsing* phase from the *usage* phase, so that
  I have to do the parsing once and reuse it over and over. I noticed
  that the actual generation of the result is interspersed in the
  parsing, so that any new name requires going through the grammar every
  time.

The supported *language* is described in the [Fantasy Name Generator
instructions][]. The grammar is the following:

```
LITERAL ::= /[^|()<>]+/
TEMPLATE ::= /[-svVcBCimMDd']/
literal_set ::= LITERAL | group
template_set ::= TEMPLATE | group
literal_exp ::= literal_set literal_exp | literal_set
template_exp ::= template_set template_exp | template_set
literal_list ::= literal_exp "|" literal_list | literal_exp "|" | literal_exp
template_list ::= template_exp "|" template_list | template_exp "|" | template_exp
group ::= "<" template_list ">" | "(" literal_list ")"
name ::= template_list | group
```

I reshaped it to take advantage of the *star* operator, among other
things:

```
LITERAL  ::= /[^|()<>]+/
TEMPLATE ::= /[-svVcBCimMDd']+/

literal_set   ::= LITERAL  | group
literal_exp   ::= literal_set*
literal_list  ::= literal_exp  ("|" literal_exp)*

template_set  ::= TEMPLATE | group
template_exp  ::= template_set*
template_list ::= template_exp ("|" template_exp)*

group ::= "<" template_list ">" | "(" literal_list ")"

name ::= template_list | group
```

Notable differences:

- the `TEMPLATE` takes multiple template characters at once. I can then
  divide them afterwards;
- the two `_exp` definitions are actually just a sequence of the
  corresponding `_set` definitions, so we're using the *start* operator;
- the two `_list` expressions are actually the correponding expression,
  followed by a sequence of zero or more alternation separators (i.e.
  `|`) followed by another expression.

The grammar is sound and compact, although it's somehow strange that
it's been designed to be fully compatible with the original - because
the original is not *open source* and its pre-defined expressions are
not available.

I would have probably gone for something more *refactored*, using escape
characters for templates and only one grouping symbol.

Whatever.

[null program]: https://nullprogram.com/
[Fantasy Name Generator: Request for Patterns]: https://nullprogram.com/blog/2009/01/04/
[Perl]: https://www.perl.org/
[Parse::RecDescent]: https://metacpan.org/pod/Parse::RecDescent
[Fantasy Name Generator]: http://www.rinkworks.com/namegen/
[RinkWorks]: http://www.rinkworks.com/
[FantasyName.pm]: https://github.com/skeeto/fantasyname/blob/master/pl/FantasyName.pm
[Fantasy Name Generator instructions]: http://www.rinkworks.com/namegen/instr.shtml
