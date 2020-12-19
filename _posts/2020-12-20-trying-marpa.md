---
title: Trying Marpa
type: post
tags: [ perl, parsing ]
comment: true
date: 2020-12-20 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I've finally come to try out [Marpa][]. To blow a mosquito with a cannon.

It's not mystery that I usually revert to the [Parsing toolkit in cglib][]
when I have to build a parser. I mean, I wrote it and I have to give it
*some sense*.

So far, this has prevented me doing two things:

- learn *more* on what regular expressions have become in later years, and
- learn *something* about [Marpa][] (well... relese 2 at least).

This is usually related to the fact that I don't need to implement fancy
grammars, hence coding a parser at a lower level is not a real issue.

The occasion, though, came with quiz #2 in the [19th day][] of [Advent of
Code][]. While the 1st part could be easily addressed with something
definitively simpler, the same solution failed miserably with the
alternative input grammar.

At this point, instead of fiddling with my original code, I decided to climb
the giant's back and stand on its shoulders. From there, there is a good
view of the mosquito, so it's impossible to miss it with our [Marpa][]
cannon!

Here's the code that did the trick for me:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use autodie;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use File::Basename qw< basename >;
$|++;

use Marpa::R2;

my @rules;
my $filename = shift || basename(__FILE__) =~ s{\.pl\z}{.input}rmxs;
open my $fh, '<', $filename;
while (<$fh>) {
   last unless m{\S}mxs;
   chomp;
   my ($id) = m{\A (\d+):}mxs;

   s{(\d+)}{Rule$1}gmxs;
   s{:}{ ::=}gmxs;
   s{"}{'}gmxs;

   $rules[$id] = $_;
}

my $dsl = join "\n",
   ':default ::= action => [name,values]',
   'lexeme default = latm => 1',
   @rules;

my $grammar = Marpa::R2::Scanless::G->new( { source => \$dsl } );
say scalar grep { eval { s{\s+}{}gmxs; $grammar->parse(\$_) } } <$fh>;
```

The first part reads all rules in, and stores the in `@rules` in ascending
order. This will also allow putting rule `0` at the beginning and make it
the *default* rule.

While reading input rules in, we also transform them on the fly in a format
that will be good for [Marpa::R2][Marpa]. In particular, we prepend the
string `Rule` to every rule, transform plain `:` colon character in the
so-called *BNF operator* `::=` and turn double quotes in single ones. In
other terms, just a few adaptations on the format.

In practice, this:

```text
0: 1 2
1: "a"
2: 1 3 | 3 1
3: "b"
```

is turned into this:

```text
Rule0 ::= Rule1 Rule2
Rule1 ::= 'a'
Rule2 ::= Rule1 Rule3 | Rule3 Rule1
Rule3 ::= 'b'
```

Variable `$dsl` eventually holds our whole grammar, with the addition of  a
pair of initial configurations taken straight from the [SYNOPSIS][]:

```text
:default ::= action => [name,values]
lexeme default = latm => 1
Rule0 ::= Rule1 Rule2
Rule1 ::= 'a'
Rule2 ::= Rule1 Rule3 | Rule3 Rule1
Rule3 ::= 'b'
```

Building the grammar text was really the hard part, because [Marpa][] can do
the rest from now on. We get an object `$grammar` that can parse valid
inputs, then use it to filter the several input strings. The `eval` in the
`grep` is necessary because inputs that fail to be matched will result in an
exception. so we need to catch it. Additionally, `grep` in this case is very
useful to *count* things, which is what we are requested to do.

This solution is completely general, so it can be applied both to the
original input and to the modified one. I've found it easier to have *two*
input files, one for each step in the day 19 challenge. You might want to do
differently!

So... thanks to [Jeffrey Kegler][] for saving my day 🙄


[Parsing toolkit in cglib]: /2020/07/11/parsing-toolkit/
[Marpa]: https://metacpan.org/pod/Marpa::R2
[19th day]: https://adventofcode.com/2020/day/19
[Advent of Code]: https://adventofcode.com/
[SYNOPSIS]: https://metacpan.org/pod/Marpa::R2#Synopsis
[Jeffrey Kegler]: http://www.jeffreykegler.com/
