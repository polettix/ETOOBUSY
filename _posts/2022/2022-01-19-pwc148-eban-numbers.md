---
title: PWC148 - Eban Numbers
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-01-19 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#148][]. Enjoy!

# The challenge

> Write a script to generate all Eban Numbers <= 100.
>
>> An Eban number is a number that has no letter ‘e’ in it when the
>> number is spelled in English (American or British).
>
> ***Example**
>
>     2, 4, 6, 30, 32 are the first 5 Eban numbers.


# The questions

I think that *number* means positive or non-negative integer, right?
(Either way, z**E**ro would be out).

# The solution

This week I felt lazy and decided that *giants are my friends*. So I
took a look at [CPAN][] and *presto!*, there I found
[Lingua::EN::Numbers][].

Well... right, it's customary for me to start with [Raku][] for the
first challenge, but *presto!*, there was an equally named module for
[Raku][] too: [Lingua::EN::Numbers][len-raku].

So the algorithm is pretty basic: convert the numbers in their English
wording, then *ban* the *e*s:

```raku
#!/usr/bin/env raku
use v6;
use Lingua::EN::Numbers;
sub MAIN (Int:D $max = 100) { ebans-upto($max)».put }
sub ebans-upto (Int:D $max) { (^$max).grep({cardinal($_) !~~ /:i e/}) }
```

The case-insensitive match is probably overkill but it's part of being
*defensive*. Who knows when and where I'm going to reuse this code?!?

OK, [Perl][] now:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use FindBin '$Bin';
use lib "$Bin/local/lib/perl5";
use Lingua::EN::Numbers 'num2en';
map { say } ebans_upto(shift // 100);
sub ebans_upto ($max) { grep {num2en($_) !~ /e/i } 1 .. $max };
```

Nothing new or different.

Had I to do this differently, I'd probably observe that:

- everything matching `/ [1789] /mxs` is out (one for various reasons)
- everything matching `/ 2\d \z/mxs` is out too
- everything matching `/ [35] \z/mxs` or `/ [35]\d\d \z/mxs` is out
- everything else *should* be in.

So the solution might even have been this, hopefully valid for any input
(not only 100) until proven otherwise:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
sub is_eban ($n) { $n !~ m{ [1789] | (?:2\d\z) | (?:[35](?:\d\d)?\z) }mxs }
is_eban($_) && say for 1 .. shift // 100;
```

But I'm a lazy folk so I'll stick to the modules-based solution.

Stay safe and see you soon!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#148]: https://theweeklychallenge.org/blog/perl-weekly-challenge-148/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-148/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[CPAN]: https://metacpan.org/
[Lingua::EN::Numbers]: https://metacpan.org/pod/Lingua::EN::Numbers
[len-raku]: https://raku.land/github:thundergnat/Lingua::EN::Numbers
