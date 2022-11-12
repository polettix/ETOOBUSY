---
title: PWC114 - Higher Integer Set Bits
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-05-27 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#114][].
> Enjoy!

# The challenge


> You are given a positive integer `$N`.
> 
> Write a script to find the next higher integer having the same number
> of 1 bits in binary representation as `$N`.
> 
> **Example**
> 
>     Input: $N = 3 Output: 5
> 
>     Binary representation of $N is 011. There are two 1 bits. So the
>     next higher integer is 5 having the same the number of 1 bits i.e.
>     101.
> 
>     Input: $N = 12 Output: 17
> 
>     Binary representation of $N is 1100. There are two 1 bits. So the
>     next higher integer is 17 having the same number of 1 bits i.e.
>     10001.

# The questions

Apart from assuming that the *input representation* will *necessarily*
be in base 10, I guess that no further clarifications are necessary.

# The solution

As I said in previous post [PWC114 - Next Palindrome Number][],
challenges can be addressed via *brute force* or with *aimed*
strategies.

Well, this time I opted for *brute force* 🙄

I first take note of the number of bits in the input. Then I start
counting from the successor, until I find a number with the same amount
of bits. Soooo boring.

Here's the complete program in [Perl][]:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub higher_integer_set_bits ($N) {
   sub n_bits ($x) { sprintf('%b', $x) =~ tr/1/1/ };
   my $initial = n_bits($N);
   while ('necessary') {
      ++$N;
      return $N if $initial == n_bits($N);
   }
}

@ARGV = 3 unless @ARGV;
say higher_integer_set_bits($_) for @ARGV;
```

Here's the correspondent program in (baby) [Raku][]:

```raku
#!/usr/bin/env raku
use v6;

sub higher-integer-set-bits (Int $N is copy) {
   sub n-bits ($x) { ($x.base(2) ~~ m:g/1/).elems };
   my $initial = n-bits($N);
   while True {
      ++$N;
      return $N if $initial == n-bits($N);
   }
}

sub MAIN (*@inputs is copy) {
   @inputs.push(3) unless @inputs.elems;
   higher-integer-set-bits($_).say for @inputs;
}
```

The old trick of counting stuff using the `tr` operator seems to be gone
for good. We're resorting to counting the matches, hoping it's not that
bad efficiency-wide (I mean, it will be a limited amount of bits
anyway).

Stay safe folks!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#114]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-114/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-114/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[PWC114 - Next Palindrome Number]: {{ '/2021/05/26/pwc114-next-palindrome-number/' | prepend: site.baseurl }}
