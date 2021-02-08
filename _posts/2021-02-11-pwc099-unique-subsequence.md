---
title: PWC099 - Unique Subsequence
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-02-11 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#099][].
> Enjoy!

# The challenge

> You are given two strings `$S` and `$T`. Write a script to find out
> count of different unique subsequences matching `$T` without changing
> the position of characters.


# The questions

I have to admit that I didn't understand the wording in the first place,
thinking that a "subsequence" had somehow to be formed by consecutive
letters. The examples, though, make it pretty clear that this is not the
case.


# The solution

I coded two different solutions to this challenge because it gave me two
itches to scratch.

On the one hand, I immediately thought of a recursive implementation
that should work and be reasonably easy *and* readable. So... why not?

On the other hand, there's matching involved, and the [TASK #1][] was
about matching too, with a few substitutions. So... why not?

## The (explicitly) recursive solution

The following function implements the recursive solution, at least the
*explicit* one:

```perl
sub unique_subsequence ($S, $T) {
   my $lenT = length $T or return 1;
   my $lenS = length $S or return 0;
   my $first = substr $T, 0, 1, '';
   --$lenT;
   my $s = 0; # sum
   my $p = 0; # search start position
   while (($p < $lenS) && (my $i = index $S, $first, $p) >= $p) {
      $s += unique_subsequence(substr($S, $i), $T) if $lenS - $i >= $lenT;
      $p = $i + 1;
   }
   return $s;
}
```

As any good recursive function, the first lines are devoted to checking
the corner cases where the recursion should be stopped and a decision
taken.

If we get an empty `$T`, it means that we were able to match all
characters in the initial `$T`, so it's a match - return `1`.

Otherwise, if we get an empty `$S`... we didn't manage to match the
whole pattern `$T`, so it's a failure - return `0`.

At this point, we concentrate on the first character in `$T`, removing
it. This is the next character we're off to look for in `$S`; actually,
we will look for *all* of its instances in `$S`, which is why the search
(using `index`) is in a `while` loop.

For each one we find, we *potentially* recurse and accumulate the
result. Here, *potentially* means that if we already know that we don't
have enough characters, it makes no sense to recurse.

At each loop we also advance our starting position for searching via
`index`, i.e. `$p`.

At the end of the loop, `$s` holds all successes we got, so we can
return them up.

## The regular expression solution

If `$T` is `abc`, matching it actually means matching `a.*b.*c` in
regular expressions terms. So why not use it?

Well... regular expressions are normally used to establish if *one*
match exist, not to count *how many of them* are there. If only existed
a way to count them all...

Well, it seems that [there is a way][].

Which leads us straight to our solution:

```perl
sub unique_subsequence_rx ($S, $T) {
   $T = join '.*', split m{}mxs, $T;
   my $count = 0;
   1 while $S =~ m{$T(?{++$count})(?!)};
   return $count;
}
```

The basic trick here is to leverage a match with a `(?{})` block, which
executes some [Perl][] code (in our case, incrementing the counter) and
then immediately fail with a `(?!)`, forcing the regular expressions
engine to try another attept at matching, until it will have none left.

Neat!

## The whole thing

Here's the whole script, should you be curious:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub unique_subsequence ($S, $T) {
   my $lenT = length $T or return 1;
   my $lenS = length $S or return 0;
   my $first = substr $T, 0, 1, '';
   --$lenT;
   my $s = 0; # sum
   my $p = 0; # search start position
   while (($p < $lenS) && (my $i = index $S, $first, $p) >= $p) {
      $s += unique_subsequence(substr($S, $i), $T) if $lenS - $i >= $lenT;
      $p = $i + 1;
   }
   return $s;
}

sub unique_subsequence_rx ($S, $T) {
   $T = join '.*', split m{}mxs, $T;
   my $count = 0;
   1 while $S =~ m{$T(?{++$count})(?!)};
   return $count;
}

my $string = shift // 'littleit';
my $subsequence = shift // 'lit';
say unique_subsequence($string, $subsequence);
say unique_subsequence_rx($string, $subsequence);
```

Stay safe!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#099]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-099/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-099/#TASK2
[Perl]: https://www.perl.org/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-099/#TASK1
[there is a way]: https://www.perlmonks.org/?node_id=1066363
