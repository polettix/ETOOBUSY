---
title: PWC083 - Words Length
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-10-21 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#083][]. Enjoy!

# The challenge

> You are given a string $S with 3 or more words. Write a script to find
> the length of the string except the first and last words ignoring
> whitespace.

# The questions

Well, the first question is *what's a word*? Can we consider it as *any
sequence of non-spacing characters*? This is what we will assume from
now on, anyway.

Next is... is the string allowed to start with empty spaces, or end with
them? Or is it always trimmed?

An aside question out of curiosity: why do we get rid of the first and
last words?!?

# The solution

There are many ways to do this that come to mind, let's pick one:

```perl
sub words_length ($text) {
    length($text =~ s{\A \s* \S+ | \s+ | \S+ \s* \z}{}grmxs);
}
```

A little *cryptic*, uh?

The idea is to take the input string `$text` and get rid of everything
that should not participate into the counting, using the *substitution
operator* [s][]. So we can get rid of the first word like this:

```perl
$text ~= s{\A \s* \S+}{}mxs;
```

i.e. by attaching to the beginning of `$text` (`\A`), removing the
optional initial whitespace and then as many non-spacing characters as
possible.

Similarly, we can proceed with the last word:

```perl
$text =~ s{\S+ \s* \z}{}mxs;
```

Last, we can get rid of all spaces:

```perl
$text =~ s{\s+}{}gmxs;
```

Note that we're including the `/g` modifier here, because we want to
remove all of them, not only the first batch we encounter. 

It turns out that we can combine all of them, thanks again to the `/g`
modifier... so there we go, the initial solution!

As a final touch, we're using the `/r` modifier, which makes sure to
leave the original string untouched and return a modified copy instead.
So at this point, the only thing left is to count the number of
characters with `length`.

The full code, should you want to try that out:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

say words_length(shift || 'The Weekly Challenge');

sub words_length ($text) {
   length($text =~ s{\A \s* \S+ | \s+ | \S+ \s* \z}{}grmxs);
}
```


[s]: https://perldoc.perl.org/perlop#Regexp-Quote-Like-Operators
[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#083]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-083/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-083/#TASK1
