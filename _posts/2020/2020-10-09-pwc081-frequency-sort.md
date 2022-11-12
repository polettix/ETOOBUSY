---
title: PWC081 - Frequency Sort
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-10-09 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> On to [Perl Weekly Challenge][] issue [#081][] [TASK #2][].

I think that this was a solid *simplish* challenge that in hindsight was
not really *that simple*. I mean, while solving it I realized that there
were a lot of things that have become some kind of *muscle memory* for
me, but are not to be taken for granted in general.

Or maybe I just found an overcomplicated solution.

# The challenge

> You are given file named input. Write a script to find the frequency
> of all the words. It should print the result as first column of each
> line should be the frequency of the the word followed by all the words
> of that frequency arranged in lexicographical order. Also sort the
> words in the ascending order of frequency.

Additionally:

> For the sake of this task, please ignore the following in the input
> file: `. " ( ) , 's --`

# The questions

One thing that I immediately thought was *how general should this be*?
The addendum about ignoring a few things in the input--mostly
punctuation, but also the `'s`-- really got me interested into knowing
whether these really cover the whole gamut of *throwables* in a general
text. Like: square and curly brackets anyone? Question marks?
Exclamations? You get the idea.

Another interesting thing is the file that is named `input`. Is it
l-i-t-e-r-a-l-l-y named `input`? That's curious. Or maybe not.

Other curiosities: should we think case-insentively? Intuitively we
should, probably, although the thing might become a bit more complicated
than one might think (hint: turning all to lowercase or all to uppercase
would probably bite you on some input text, see [Case Folding][] for
more).

Last, the double newline that separates two rows intrigued me a bit. Is
it really meant to be there?


# The solution

Without further ado, let's look at my solution:

```
 1 sub frequency_sort ($input = 'input') {
 2 
 3    # Allow for getting an open filehandle as input
 4    my $fh = ref($input) ? $input : do {open my $fh, '<', $input; $fh};
 5 
 6    # Count occurrences for all words, just for starters
 7    my %count_for;
 8    while (<$fh>) {
 9       s{(?: [."(),] | 's | -- )+}{ }gmxs; # ignore stuff
10       $count_for{$_}++ for grep {length > 0} split m{\s+}mxs;
11    }
12 
13    # Invert "count by word" to "words by count"
14    my %words_for;
15    while (my ($word, $count) = each %count_for) {
16       push $words_for{$count}->@*, $word;
17    }
18 
19    say join "\n\n", map {
20       # Sort words for $count lexicographically
21       join ' ', $_, sort {$a cmp $b} $words_for{$_}->@*;
22    } sort {$a <=> $b} keys %words_for;
23 }
```

As anticipated, there's a lot to unpack because we're doing some
back-and-forth here:

- line 4 is just a trick to accept a filehandle as input in addition to
  a filename whose value is `input` literally (which is assumed by
  default though);

- in the actual algorithm, first of all, we read all the input, break it
  into *words* and keep a count for all of them in a hash. This happens
  in lines 7 to 11. Here, keys are words and values are counts;

- at this point, we *invert* this index to have a hash that is indexed
  *by count* and keeps arrays of words with that count. This happens in
  lines 14 to 17;

- last, we sort the counts and use them to access the hash in the right
  order (lines 19 to 22). While we are at it, we also take care to sort
  the words in lexicographic order (line 21), relying on whatever locale
  we have (which might introduce some variations).

- leaving an empty line between outputs is easy, just put two newlines
  to separate items instead of one (line 19).

As always, here's the complete script if you want to play with it:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use autodie;

sub frequency_sort ($input = 'input') {

   # Allow for getting an open filehandle as input
   my $fh = ref($input) ? $input : do {open my $fh, '<', $input; $fh};

   # Count occurrences for all words, just for starters
   my %count_for;
   while (<$fh>) {
      s{(?: [."(),] | 's | -- )+}{ }gmxs; # ignore stuff
      $count_for{$_}++ for grep {length > 0} split m{\s+}mxs;
   }

   # Invert "count by word" to "words by count"
   my %words_for;
   while (my ($word, $count) = each %count_for) {
      push $words_for{$count}->@*, $word;
   }

   say join "\n\n", map {
      # Sort words for $count lexicographically
      join ' ', $_, sort {$a cmp $b} $words_for{$_}->@*;
   } sort {$a <=> $b} keys %words_for;
}

frequency_sort(\*DATA);

__DATA__
West Side Story

The award-winning adaptation of the classic romantic tragedy "Romeo and
Juliet". The feuding families become two warring New York City gangs,
the white Jets led by Riff and the Latino Sharks, led by Bernardo. Their
hatred escalates to a point where neither can coexist with any form of
understanding. But when Riff's best friend (and former Jet) Tony and
Bernardo's younger sister Maria meet at a dance, no one can do anything
to stop their love. Maria and Tony begin meeting in secret, planning to
run away. Then the Sharks and Jets plan a rumble under the
highway--whoever wins gains control of the streets. Maria sends Tony to
stop it, hoping it can end the violence. It goes terribly wrong, and
before the lovers know what's happened, tragedy strikes and doesn't stop
until the climactic and heartbreaking ending.
```

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#081]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-081/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-081/#TASK2
[Hacktoberfest]: https://hacktoberfest.digitalocean.com/
[Case Folding]: https://www.w3.org/TR/charmod-norm/#definitionCaseFolding
