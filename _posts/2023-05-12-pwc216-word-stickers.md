---
title: PWC216 - Word Stickers
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-05-12 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#216][].
> Enjoy!

# The challenge

> You are given a list of word stickers and a target word.
>
> Write a script to find out how many word stickers is needed to make up the
> given target word.
>
> **Example 1:**
>
>     Input: @stickers = ('perl','raku','python'), $word = 'peon'
>     Output: 2
>
>     We just need 2 stickers i.e. 'perl' and 'python'.
>     'pe' from 'perl' and
>     'on' from 'python' to get the target word.
>
> **Example 2:**
>
>     Input: @stickers = ('love','hate','angry'), $word = 'goat'
>     Output: 3
>
>     We need 3 stickers i.e. 'angry', 'love' and 'hate'.
>     'g' from 'angry'
>     'o' from 'love' and
>     'at' from 'hate' to get the target word.
>
> **Example 3:**
>
>     Input: @stickers = ('come','nation','delta'), $word = 'accommodation'
>     Output: 4
>
>     We just need 2 stickers of 'come' and one each of 'nation' & 'delta'.
>     'a' from 'delta'
>     'ccommo' from 2 stickers 'come'
>     'd' from the same sticker 'delta' and
>     'ation' from 'nation' to get the target word.
>
> **Example 4:**
>
>     Input: @stickers = ('come','country','delta'), $word = 'accommodation'
>     Output: 0
>
>     as there's no "i" in the inputs.

# The questions

Oh my goodness where did this come from? The input text is totally obscure
to the verge of being totally useless, but I hope I got the example right
and folks I did like it!

# The solution

> **Update** thanks to [E. Choroba][choroba] I discovered **two** bugs...
> the joys of testing (or lack thereof...)

The key word here is *needed*. So... it's an optimization problem, and we
have to find out the lowest number of available stickers from which we can
generate our target word.

First of all, we can address each letter by itself. Who cares to have a few
less cuts, when cuts are not explicitly mentioned and we're just interested
into the total count, right?

So the first thing we will do is to write down the recipe for our cake, that
is count how many instances we need for each letter. This ends up in
`%needed`, a hash indexed by letter and whose values are counts (as
integers).

Next, we compute what we have in the fridge, i.e. the ingredients that we
have at our disposal. Each sticker will give us some of this and some of
that, which we collect into `%provided`. This is a two-levels hash
(*hash-of-hashes*), first indexed by letter (only keeping the ones that we
actually need, from `%needed`), then by the word that is providing us that
letter. The value is, again, a count of how many of that letter can be
extracted from that sticker.

Next we can compute our rock bottom, bare minimum amount of words that we
can'd do without. This is represented by all those letters where we only
have one single possible source sticker. While at it, we can also check that
there's no letter that has no source, and fail fast if this is the case,
returning `0` for good.

Next we *use* the bare minimum amount of words to see what we cover and
what's left. All `%needed` items that have a single source will be removed,
of course, and we'll also chip off some other letter hopefully. At the end
of this stage, `%needed` tells us what's left that we have to cover, if
anything.

If it *actually* still has some requirements, then it's time to do some
search for an optimal solution, i.e. adding the bare minimum amount of
stickers to get the job done. To do this, one possible approach is to play
it safe and do a *breadth-first* search, that is moving as little steps as
possible while looking for a solution. In other terms, we will exaust all
possible ways of taking other `N` stickers before trying to take `N+1`
stickers. When we eventually complete the job, we know that we got to the
minimum, and we call it a day. This is what `complete_minimum` does in the
code below.

So... the code:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
use List::Util 'sum';

say word_stickers(qw< ppeoknpp perlp raku python >);

sub word_stickers ($word, @stickers) {
   my %needed = letters_histogram($word);

   # collect whatever is deemed sufficient
   my %provided;
   for my $sticker (@stickers) {
      my %available = letters_histogram($sticker);
      for my $letter (keys(%needed)) {
         my $available = $available{$letter} or next;
         $provided{$letter}{$sticker} = $available;
      }
   }


   # check for a viable solution and set the bare minimum
   my %minimum;
   for my $letter (keys(%needed)) {
      my $alternatives = $provided{$letter}
         or return 0; # no viable source
      if (scalar(keys($alternatives->%*)) == 1) { # one viable source only
         my ($word, $units) = $alternatives->%*;
         my $amount = int($needed{$letter} / $units)
            + ($needed{$letter} % $units ? 1 : 0);
         my $amount = $units;
         $minimum{$word} = $amount
            if (! exists($minimum{$word})) || ($minimum{$word} < $amount);
      }
   }

   # use whatever minimum we set to lower needs, where possible
   for my $letter (keys(%needed)) {
      my $needed = delete $needed{$letter};
      for my $source (keys($provided{$letter}->%*)) {
         $needed -= ($minimum{$source} // 0) * $provided{$letter}{$source};
      }
      $needed{$letter} = $needed if $needed > 0; # restore missing
   }

   # if we're left with needs, we have to do some searching, breadth first
   %minimum = complete_minimum(\%minimum, \%needed, \%provided)
      if scalar(keys(%needed));

   return sum(values(%minimum));
}

sub complete_minimum ($minimum, $needed, $provided) {
   my @queue = ({needed => {$needed->%*}, minimum => {$minimum->%*}});
   while (@queue) {
      my $frame = shift(@queue);
      my $needed = $frame->{needed};
      my $minimum = $frame->{minimum};

      my %words = map { $_ => 1 }
         map { keys($provided->{$_}->%*) } keys($needed->%*);
      for my $source (keys %words) {
         my %nmin  = $minimum->%*;
         $nmin{$source}++;
         my %nneed = $needed->%*;
         for my $letter (keys(%nneed)) {
            $nneed{$letter} -= $provided->{$letter}{$source} // 0;
            delete($nneed{$letter}) if $nneed{$letter} <= 0;
         }
         return %nmin if scalar(keys(%nneed)) == 0;
         push @queue, {needed => \%nneed, minimum => \%nmin};
      }
   }
}

sub letters_histogram ($word) {
   my %amount_for;
   $amount_for{substr($word, $_, 1)}++ for 0 .. length($word) - 1;
   return %amount_for;
}
```

I hope the [Raku][] translation is correct, it seems to work on a few test
inputs and at least it doesn's smoke:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Str :$word, *@stickers) { put word-stickers($word, @stickers) }

sub word-stickers ($word, @stickers) {
   my %needed = letters-histogram($word);

   # collect whatever is deemed sufficient
   my %provided;
   for @stickers -> $sticker {
      my %available = letters-histogram($sticker);
      for %needed.keys -> $letter {
         my $available = %available{$letter} or next;
         %provided{$letter}{$sticker} = $available;
      }
   }

   # check for a viable solution and set the bare minimum
   my %minimum;
   for %needed.keys -> $letter {
      my $alternatives = %provided{$letter}
         or return 0; # no viable source
      if ($alternatives.elems == 1) { # one viable source only
         my ($word, $units) = $alternatives.kv;
         my $amount = (%needed{$letter} div $units)
            + ((%needed{$letter} % $units) ?? 1 !! 0);
         %minimum{$word} = $amount
            if %minimum{$word}:!exists || (%minimum{$word} < $amount);
      }
   }

   # use whatever minimum we set to lower needs, where possible
   for %needed.keys -> $letter {
      my $needed = %needed{$letter}:delete;
      for %provided{$letter}.keys -> $source {
         $needed -= (%minimum{$source} // 0) * %provided{$letter}{$source};
      }
      %needed{$letter} = $needed if $needed > 0; # restore missing
   }


   # if we're left with needs, we have to do some searching, breadth first
   %minimum = complete-minimum(%minimum, %needed, %provided)
      if %needed.keys.elems > 0;

   return sum(values(%minimum));
}

sub letters-histogram ($word) {
   my %amount_for;
   %amount_for{$word.substr($_, 1)}++ for 0 ..^ $word.chars;
   return %amount_for;
}


sub complete-minimum (%minimum is copy, %needed is copy, %provided) {
   my @queue = {needed => %needed, minimum => %minimum},;
   while @queue {
      my $frame = @queue.shift;
      my $needed = $frame<needed>;
      my $minimum = $frame<minimum>;

      my %words = $needed.keys.map({ %provided{$_}.keys }).flat.map({ $_ => 1 });
      for %words.keys -> $source {
         my %nmin  = %$minimum;
         %nmin{$source}++;
         my %nneed = %$needed;
         for %nneed.keys -> $letter {
            %nneed{$letter} -= %provided{$letter}{$source} // 0;
            %nneed{$letter}:delete if %nneed{$letter} <= 0;
         }
         return %nmin if %nneed.keys.elems == 0;
         @queue.push: {needed => %nneed, minimum => %nmin};
      }
   }
   return ();
}
```

Stay safe and cheers!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#216]: https://theweeklychallenge.org/blog/perl-weekly-challenge-216/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-216/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[choroba]: https://github.com/choroba
