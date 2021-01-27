---
title: PWC097 - Caesar Cipher
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-01-27 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#097][]. Enjoy!

# The challenge

> You are given string `$S` containing alphabets `A..Z` only and a number `$N`.
> Write a script to encrypt the given string `$S` using Caesar Cipher with left
> shift of size `$N`.

# The questions

Well well...

- regarding the input, what should we do for characters that are not in the
  alphabeth? Like... *spaces*?
    - *we will map any non-alphabeth character onto itself*
- is the number allowed to be negative or go beyond 26?
    - *we will consider a circular approach, using the rest modulo 26*

# The solution

It's time for the **evil `eval`**! [Again][PWC090 - DNA Sequence]! The
[tr][] operator is too good to be ignored for this task:

```perl
sub caesar_cipher ($S, $N) {
   $N %= 26;
   my $to   = join '', 'A' .. 'Z';
   my $from = substr($to, $N) . substr($to, 0, $N);
   return eval "\$S =~ tr/$from/$to/r";
}
```

As anticipated, we normalize `$N` to only be a shift between `0` and `25`
(included).

As [tr][] wants a *from* and a *to* characters lists, we build them.
We're asked to do a *left shift*, so it's easiery to start from the
destination `$to` (that is just the letters in normal alphabetical
order) and then build the source `$from` by taking the last part and
putting it into the front.

The rest is a trivial usage of the [tr][] operator, with the same twist
that we already saw in previous post [PWC090 - DNA Sequence][], that is
wrapping it inside an **evil `eval`** to allow for the source and the
destination characters list to be expanded from a variable (they would
normally be taken literally).

Don't you like it? Code it differently! 😉

The whole script, should you be curious:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub caesar_cipher ($S, $N) {
   $N %= 26;
   my $to   = join '', 'A' .. 'Z';
   my $from = substr($to, $N) . substr($to, 0, $N);
   return eval "\$S =~ tr/$from/$to/r";
}

my $input = shift || 'THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG';
my $n = shift || 3;
say $input;
say caesar_cipher($input, $n);
```

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#097]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-097/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-097/#TASK1
[Perl]: https://www.perl.org/
[tr]: https://perldoc.perl.org/functions/tr
[PWC090 - DNA Sequence]: {{ '/2020/12/11/pwc090-dna-sequence/' | prepend: site.baseurl }}
