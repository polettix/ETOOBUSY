---
title: PWC154 - Missing Permutation
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-03-02 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#154][]. Enjoy!

# The challenge

> You are given possible permutations of the string `'PERL'`.
>
>     PELR, PREL, PERL, PRLE, PLER, PLRE, EPRL, EPLR, ERPL,
>     ERLP, ELPR, ELRP, RPEL, RPLE, REPL, RELP, RLPE, RLEP,
>     LPER, LPRE, LEPR, LRPE, LREP
>
> Write a script to find any permutations missing from the list.

# The questions
 
One thing that's not entirely clear is whether one permutation should be
found or more. The title seems to imply the former, while the wording
seems to point to the latter.

In a generalization of the challenge, it would be interesting to know
how to deal with repeated letters. But we're not in that generazation,
right?


# The solution

Our approach will be some plain brute force: iterate through all
possible permutations and print out only the ones that are not present
in the inputs.

[Raku][] goes first and it provides us with a fantastic built-in
`permutations`. which does the heavy lifting. It does the permutations
magic acting over an input list-y thing, so we `comb` one of the
*present* combinations (it does not matter which, they all contain the
same letters). Assembling each permutation back to a string is a
fantastic option to brag about hyperoperators:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { .put for missing-permutations(@args) }

sub missing-permutations (@present) {
   my %present = @present.map({$_ => 1});
   permutations(                  # consider all permutations
         @present[0].comb(/./)    # over letters of the first item
      )».join('')                 # merge each back to a string
      .grep({!%present{$_}++});   # and keep only the unseen
}
```

The astute reader might object to the use of an additional hash to test
the presence of a combination, and they would be right in suggesting
that the final `grep` might just be:

```raku
...
      .grep({!($_ ∈ @present)});   # and keep only the unseen
...
```

Only I liked to code a generalizable solution, and this takes care of
filtering out duplicates in case of input words with duplicate
letters...

The [Perl][] alternative goes on the same wavelength, except that now we
have to code our own `permutations` (stolen from [Permutations with
Heap's Algorithm][]) and the hyperoperator is substitued with a `map`:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say for missing_permutations(@ARGV);

sub missing_permutations (@present) {
   my %present = map { $_ => 1 } @present;
   return grep {!$present{$_}++}
      map { join '', $_->@* }
      permutations(split m{}mxs, $present[0]);
}

sub permutations (@present) {
   my @indexes = 0 .. $#present;
   my @stack = (0) x @indexes;
   my @retval = [@present[@indexes]];
   my $sp = 0;
   while ($sp < @indexes) {
      if ($stack[$sp] < $sp) {
         my $other = $sp % 2 ? $stack[$sp] : 0;
         @indexes[$sp, $other] = @indexes[$other, $sp];
         push @retval, [@present[@indexes]];
         $stack[$sp]++;
         $sp = 0;
      }
      else {
         $stack[$sp++] = 0;
      }
   }
   return @retval;
}
```

I guess it's everything for this post, stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#154]: https://theweeklychallenge.org/blog/perl-weekly-challenge-154/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-154/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Permutations with Heap's Algorithm]: {{ '/2021/01/29/permutations-algorithm/' | prepend: site.baseurl }}
