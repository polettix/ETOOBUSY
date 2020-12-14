---
title: PWC091 - Count Number
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-12-15 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#091][]. Enjoy!

# The challenge

> You are given a positive number `$N`. Write a script to count number and
> display as you read it.

# The questions

Well well... here I guess my question is whether we *really* want to
consider the input a *number*, as opposed to a *string*. I mean, we're
*handling* it as a string, right? Why constraint it to be a number, with all
limitations in terms of integer representation?

I guess we can trust our inputs, otherwise the usual care should be taken -
e.g. consider something that is not a number, negative stuff, empty string,
...

# The solution

Let's start from something that didn't work, then move on...

## The epic fail!

My first instinct here was to be *clever*. How I would love to be clever!
Alas, this always seems to be deferred to some distant future.

I wanted to do something like this:

```perl
join '', map { ... } clever_regex_to_capture_sequences($N); 
```

So I thought... surely something using `\1` will help me?

```perl
join '', map { ... } ($N =~ m{.\1*}gmxs);
```

**Ehr...** there's no capture there! What is `\1` referring to?!? OK, let's put
it:

```perl
join '', map { ... } ($N =~ m{(.)\1*}gmxs);
```

**AHEM** now we're only capturing the *first* character in each sequence...
we have to take them all:

```perl
join '', map { ... } ($N =~ m{((.)\1*)}gmxs);
```

**BUT... BUT...** now the initial character is captured within the *second*
set of round parentheses! *Oh my*...

```perl
join '', map { ... } ($N =~ m{((.)\2*)}gmxs);
```

**I think it's better to stop here** because now we're capturing *two*
things and the `map` is going to have a hard time...


## Insisting on regular expression

Now I was in full regex mode, and so I moved on with this:

```perl
sub count_number ($N) {
   my $retval = '';
   while (length $N) {
      my ($sequence, $char) = $N =~ m{((.)\2*)}mxs;
      my $n = length $sequence;
      $retval .= $n . $char;
      substr $N, 0, $n, '';
   }
   return $retval;
}
```

I capture the sequence *and* the character, count the length of the
sequence, add it to the result, then chop it from the start of the
**string**. *Oh yes sure... the **number**, the **number***.

## Maybe it's a cannon for a mosquito?

I don't know, the solution with the regular expression was not that compact
after all, so I figured... maybe something more readable, although low
level?

```perl
sub count_number_2 ($N) {
   my $len = length $N;
   my ($retval, $previous, $count) = ('', '', 0);
   for my $i (0 .. $len) {
      my $c = $i < $len ? substr($N, $i, 1) : '';
      if ($c eq $previous) { ++$count }
      else {
         $retval .= $count . $previous if $count;
         ($previous, $count) = ($c, 1);
      }
   }
   return $retval;
}
```

This iterates over *indices* to get one char at a time. Plus one
past-the-end character, to make sure the last sequence is properly handled
too. Apart from this, it's just plain old boring counting of sequences,
adding something to the `$retval` when it makes sense.

# Conclusion

Well... it seems I'll have to wait for the next time to try again and feel
*clever*.

Until then... please folks stay safe!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#091]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-091/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-091/#TASK1
[Perl]: https://www.perl.org/
