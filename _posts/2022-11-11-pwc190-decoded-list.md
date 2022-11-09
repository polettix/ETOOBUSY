---
title: PWC190 - Decoded List
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-11-11 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#190][].
> Enjoy!

# The challenge

> You are given an encoded string consisting of a sequence of numeric
> characters: 0..9, `$s`.
>
> Write a script to find the all valid different decodings in sorted
> order.
>
>> Encoding is simply done by mapping A,B,C,D,… to 1,2,3,4,… etc.
>
> **Example 1**
>
>     Input: $s = 11
>     Ouput: AA, K
>
>     11 can be decoded as (1 1) or (11) i.e. AA or K
>
> **Example 2**
>
>     Input: $s = 1115
>     Output: AAAE, AAO, AKE, KAE, KO
>
>     Possible decoded data are:
>     (1 1 1 5) => (AAAE)
>     (1 1 15)  => (AAO)
>     (1 11 5)  => (AKE)
>     (11 1 5)  => (KAE)
>     (11 15)   => (KO)
>
> **Example 3**
>
>     Input: $s = 127
>     Output: ABG, LG
>
>     Possible decoded data are:
>     (1 2 7) => (ABG)
>     (12 7)  => (LG)

# The questions

I appreciate that we *challenged people* are considered capable of
quickly grasping the gist of a challenge from a few examples, but
sometimes they might be lacking some detail.

In this case, for example:

- what to do of sub-sequences that start with 0? I'm personally going to
  ignore them.
- is it correct to assume that we're considering only English uppercase
  letters here?

# The solution

There are a few moving parts in my overcomplicated reasoning:

- to make candidate groups from the input strings, we can insert a
  virtual slot between any two consecutive characters and then assign
  values to these slots, namely a separator (like a space character) or
  a merger (like the empty string). This, in turn, can be mapped onto
  counting up to $2^s$, where $s$ is the number of these virtual slots,
  then considering the binary representation and say that `0` means
  merging and `1` means separating.
- Then, of course, we have to consider that not all groupings are
  correct, and some lead to invalid mappings. So we have to filter them
  out and transform the other ones.

My [Perl][] solution considers each part within an *iterator*; the
iterators are *composed*, where outer ones feed from the inner ones.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

# finds all ways of getting items close or separated. Each run of the
# iterator provides an array reference with a grouping.
my $groups_it = all_consecutive_groupings_iterator(shift // '1115');

# filters and transforms groupings into a target string. Each run of the
# iterator provides back a valid target decoded string.
my $dl_it = decoded_list_iterator($groups_it);

# expands an iterator in an array reference with all items
my $decoded_list = iterator_to_arrayref($dl_it);

# print it out
say join ', ', $decoded_list->@*;

sub iterator_to_arrayref ($it) {
   my @retval;
   while (my @stuff = $it->()) { push @retval, @stuff }
   return \@retval;
}

sub decoded_list_iterator ($groups_it) {
   state $letter_at = [undef, 'A' .. 'Z']; # starting at 1
   return sub {
      ARRANGEMENT:
      while (my $arrangement = $groups_it->()) {
         my @candidate = map {
            next ARRANGEMENT if m{\A 0 }mxs; # nothing starting with 0
            next ARRANGEMENT if $_ > $letter_at->$#*;
            $letter_at->[$_];
         } $arrangement->@*;
         return join '', @candidate;
      }
      return;
   }
}

sub all_consecutive_groupings_iterator ($string) {
   my @items = split m{}mxs, $string;
   my $n = 2 ** $#items;
   return sub {
      return if --$n < 0;
      my $code = sprintf '%b', $n; # decide which gets tied and which not

      # turn into spaces or empty strings (ties)
      my @code = map { $_ ? ' ' : '' } split m{}mxs, $code;
      unshift @code, '' while @code < $#items;

      # well... this can be enhanced a bit!!!
      return [ split m{\s+}mxs, join '', zip_loose(\@items, \@code)->@* ];
   };
}

# merge two lists together, until *both* have been used completely
sub zip_loose ($As, $Bs) {
   my ($Ai, $Bi) = (0, 0);
   my @retval;
   while ('necessary') {
      my $Aok = ($Ai <= $As->$#*) ? 1 : 0;
      my $Bok = ($Bi <= $Bs->$#*) ? 1 : 0;
      last unless $Aok || $Bok;
      my @chunk = (
         ($Aok ? $As->[$Ai++] : ()),
         ($Bok ? $Bs->[$Bi++] : ()),
      );
      push @retval, @chunk;
   }
   return \@retval;
}
```

Function `zip_loose` allows us to intersperse two array, potentially
with different sizes. There's a bit of back and forth with arrays and
strings because... reasons 🙄

The [Raku][] alternative is less overeng**COUGH**sophisticated and
addresses the problems directly in a single monolith, leveraging my
beloved `gather/take` construct.

```raku
#!/usr/bin/env raku
use v6;
sub MAIN ($input = '1115') { decoded-list($input).join(', ').put }

sub decoded-list ($encoded) {
   my @atoms = $encoded.comb;
   my $first = @atoms.shift;
   my $n = 2 ** @atoms;
   return gather while --$n >= 0 {
      my @code = '%b'.sprintf($n).comb;
      @code.unshift(0) while @code < @atoms;
      @code.push(1); # final separator to close stuff
      my @sequence;
      my $current = $first;
      for ^@code -> $i {
         if @code[$i].Int > 0 { # separate, close and reopen if applicable
            my $decoded = decode-item($current) or last;
            @sequence.push: $decoded;
            if $i <= @atoms.end {
               $current = @atoms[$i];
            }
            else {
               take @sequence.join('');
               last;
            }
         }
         else { # merge with previous
            $current ~= @atoms[$i];
         }
      }
   };
}

sub decode-item ($item) {
   state @letter-at = (Nil, 'A' .. 'Z').flat;
   return if $item ~~ /^ 0/; # we consider this invalid
   return if $item.Int > @letter-at.end;
   return @letter-at[$item.Int];
}
```

As a trick, I'm always adding a fake separator at the end, so that I can
trigger the decoding of the last element. This is a trick, but a handy
one because it allows me to put the call to `decode-item()` in one
single place instead of two.

There were a few pitfalls like forgetting to add `.flat` and assuming
that string `0` is *false* like in [Perl][], which it isn't. Nothing too
complicated to address, anyway.

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#190]: https://theweeklychallenge.org/blog/perl-weekly-challenge-190/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-190/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
