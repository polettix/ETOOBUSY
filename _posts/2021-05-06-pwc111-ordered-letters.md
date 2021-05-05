---
title: PWC111 - Ordered Letters
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-05-06 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#111][].
> Enjoy!

# The challenge

> Given a word, you can sort its letters alphabetically (case
> insensitive). For example, “beekeeper” becomes “beeeeekpr” and
> “dictionary” becomes “acdiinorty”.
>
> Write a script to find the longest English words that don’t change
> when their letters are sorted.

# The questions

*Can I overengineer it?!?*

For reasons that will be clear shortly...

# The solution

I know. It says `English words`.

But but...

... I wanted to make it more *generic*.

So I took a chance to look at the [Perl Unicode Cookbook][], hoping to
not make *too much of a mess*:

```perl
#!/usr/bin/env perl
use utf8;                     # so literals and identifiers can be in UTF-8
use v5.24;
use strict;                   # quote strings, declare variables
use warnings;                 # on by default
use warnings qw(FATAL utf8);  # fatalize encoding glitches
use open qw(:std :utf8);      # undeclared streams in UTF-8
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

use Unicode::Normalize;
use Unicode::Collate;
use Encode qw(decode_utf8);

@ARGV = map { decode_utf8($_, 1) } @ARGV;

my @pairs;
while (<>) {
   my $pair = check_ordered(NFD($_)) // next;
   push @pairs, $pair;
}
say for reverse map { $_->[1] } sort { $a->[0] <=> $b->[0] } @pairs;

sub check_ordered ($x) {
   state $coll = Unicode::Collate->new(level => 1);
   state $es = Unicode::Collate->new(level => 1, normalization => undef);
   my @chars = $x =~ m{(\X)}gmxs;
   shift @chars while @chars && $chars[0] =~ m{[\h\v]}mxs;
   pop @chars   while @chars && $chars[-1] =~ m{[\h\v]}mxs;
   my $original   = join '', @chars;
   my $rearranged = join '', $coll->sort(@chars);
   return [scalar(@chars), $original] if $es->eq($original, $rearranged);
   return;
} ## end sub check_ordered ($x)
```

I have to admit that I don't understand the 100% of it. In particular,
I'm using *two* instances of [Unicode::Collate][]:

- one for sorting (`$coll`), initialized as per [Case- and
  Accent-insensitive Sorting][], and
- one for equality checking (`$eq`), initialized as per [Case- and
  Accent-insensitive Comparison][].

but I didn't really understand what the difference is.

The comparison and check is performed without caring for either case or
accent. The latter should not be an issue in English, although I noticed
that it gives the green light to words like `access's`. Go figure.

The input list for the words is taken from `/usr/share/dict/words`.

Running the program gives back *all* the words, so the filtering can be
done from the shell:

```
$ perl perl/ch-2.pl /usr/share/dict/words | head
access's
abbess's
gloss's
floss's
floor's
chino's
chimp's
chill's
cello's
billowy
```

It takes a bit... but it's hopefully *correct*.

It's interesting that the longest word composed of letters only is...
[billowy][]. Today I learned that it indicates something that is full or
forming large waves or swell of something (I guess water, usually).

Stay safe everybody!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#111]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-111/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-111/#TASK2
[Perl]: https://www.perl.org/
[Perl Unicode Cookbook]: https://www.perl.com/pub/2012/04/perlunicook-standard-preamble.html/
[Unicode::Collate]: https://metacpan.org/pod/Unicode::Collate
[Case- and Accent-insensitive Sorting]: https://www.perl.com/pub/2012/06/perlunicook-case--and-accent-insensitive-sorting.html/
[Case- and Accent-insensitive Comparison]: https://www.perl.com/pub/2012/06/perlunicook-case--and-accent-insensitive-comparison.html/
[billowy]: https://www.thefreedictionary.com/billowy
