---
title: PWC162 - Wheatstone-Playfair
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-04-27 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#162][].
> Enjoy!

# The challenge

> Implement encryption and decryption using [the Wheatstone-Playfair cipher][cipher].
>
> **Examples:**
>
>     (These combine I and J, and use X as padding.)
>
>     encrypt("playfair example", "hide the gold in the tree stump") = "bmodzbxdnabekudmuixmmouvif"
>
>     decrypt("perl and raku", "siderwrdulfipaarkcrw") = "thewexeklychallengex"

# The questions

If the example is to be taken into account, I guess that letters `I` and
`J` should be coalesced, and `X` used as a padding. Right?

# The solution

Before delving into the solution, we can see that encryption and
decryption are almost the same, except for the direction of getting
letters in the same row or column, This can be easily arranged with an
*offset* parameter to tell how much displacement we want to account for
depending on the operation.

So let's start with [Perl][] first:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say encrypt('playfair example', 'hide the gold in the tree stump');
say decrypt('perl and raku', 'siderwrdulfipaarkcrw');

sub encrypt ($key, $message) { wheatstone_playfair($key, $message, 1) }
sub decrypt ($key, $message) { wheatstone_playfair($key, $message, 5 - 1) }
```

The main workhorse is then the following function, I hope the comments
are sufficient!

```perl
sub wheatstone_playfair ($key, $message, $off) {

   # pre-massage the input, go uppercase and remove all j:s
   $_ = lc($_) =~ s{j}{i}rgmxs for $key, $message;

   # we don't need no stinkin' matrix, a bijection in two arrays is OK
   my %flag;
   my @letter_at = grep { $flag{$_}++ == 0 }
     split(m{[^a-z]?}imxs, $key), 'a' .. 'i', 'k' .. 'z', 'j';

   # the "go back" might be a hash but we are C nostalgic
   my $oA = ord('a');          # used to turn lc letters into array indexes
   my @pos_of = map { $_->[0] }   # get indexes
     sort { $a->[1] cmp $b->[1] } # sorted by letter position
     map { [$_, $letter_at[$_]] } 0 .. $#letter_at;

   # take only letters into consideration, split on everything else
   my @message = split m{[^a-z]?}imxs, $message;
   my @output;
   while (@message) {

      # first letter is whatever, second letter might be an X
      my $A = shift @message;
      my $B = @message && $message[0] ne $A ? shift @message : 'x';

      # get positions, $A and $B are spoiled on the way but it's OK
      my ($Ax, $Ay, $Bx, $By) = map {
         my $v = $pos_of[ord($_) - $oA];
         ($v % 5, int($v / 5))
      } ($A, $B);

      # apply Wheatstone-Playfair mapping
      ($Ax, $Ay, $Bx, $By) =
          $Ax == $Bx ? ($Ax, ($Ay + $off) % 5, $Bx, ($By + $off) % 5)
        : $Ay == $By ? (($Ax + $off) % 5, $Ay, ($Bx + $off) % 5, $By)
        :              ($Bx, $Ay, $Ax, $By);

      push @output, @letter_at[$Ax + 5 * $Ay, $Bx + 5 * $By];
   } ## end while (@message)
   return join '', @output;
} ## end sub wheatstone_playfair
```

I opted for a *C accent* this time, making things unnecessarily
complicated by using an array where the natural choice would be a hash.
Call it like playing NetHack with some self-imposed discipline.

> Fun fact: I don't really play NetHack, but I'd love to.

Anyway, this crazyness stops here and in [Raku][] we're on to proper
hashes:

```raku
#!/usr/bin/env raku
use v6;

put encrypt('playfair example', 'hide the gold in the tree stump');
put decrypt('perl and raku', 'siderwrdulfipaarkcrw');

sub encrypt ($key, $message) { wheatstone-playfair($key, $message, 1) }
sub decrypt ($key, $message) { wheatstone-playfair($key, $message, 5 - 1) }

sub wheatstone-playfair ($key is copy, $message is copy, $off) {
   for $key, $message { $_ = $_.lc; s:g/j/i/ }

   # we don't need no stinkin' matrix, a bijection in two arrays is OK
   my %flag;
   my @letter-at = ($key.comb(/<[a .. z]>/), 'a' .. 'i', 'k' .. 'z', 'j')
      .flat.grep({ %flag{$_}++ == 0 });

   # in Raku we're not C nostalgic any more
   my %pos-of = (0..25).map({ @letter-at[$_] => $_ });

   # take only letters into consideration, split on everything else
   my @message = $message.comb(/<[ a ..z ]>/);
   my @output;
   while @message {

      # first letter is whatever, second letter might be an X
      my $A = shift @message;
      my $B = @message && @message[0] ne $A ?? @message.shift !! 'x';

      # get positions, $A and $B are spoiled on the way but it's OK
      my ($Ax, $Ay, $Bx, $By) =
         ($A, $B).map({ my $v = %pos-of{$_}; ($v % 5, ($v / 5).Int) }).flat;

      # apply Wheatstone-Playfair mapping
      ($Ax, $Ay, $Bx, $By) =
           $Ax == $Bx ?? ($Ax, ($Ay + $off) % 5, $Bx, ($By + $off) % 5)
        !! $Ay == $By ?? (($Ax + $off) % 5, $Ay, ($Bx + $off) % 5, $By)
        !!               ($Bx, $Ay, $Ax, $By);

      @output.push: @letter-at[$Ax + 5 * $Ay, $Bx + 5 * $By].Slip;
   } ## end while (@message)
   return join '', @output;
}
```

So there we go! Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#162]: https://theweeklychallenge.org/blog/perl-weekly-challenge-162/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-162/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[cipher]: https://en.wikipedia.org/wiki/Playfair_cipher
