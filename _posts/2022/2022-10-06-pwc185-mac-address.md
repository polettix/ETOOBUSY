---
title: PWC185 - MAC Address
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-10-06 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#185][]. Enjoy!

# The challenge

> You are given `MAC address` in the form i.e. `hhhh.hhhh.hhhh`.
>
> Write a script to convert the address in the form `hh:hh:hh:hh:hh:hh`.
>
> **Example 1**
>
>     Input:  1ac2.34f0.b1c2
>     Output: 1a:c2:34:f0:b1:c2
>
> **Example 2**
>
>     Input:  abc1.20f1.345a
>     Output: ab:c1:20:f1:34:5a

# The questions

Uh... I guess none! Well...

- MAC is the Media Access Control address, right?
- `h` represents a hex digit, right?

# The solution

In [Raku][] we're using `comb` to focus on the characters that we need,
taking two at a time (without the input validation):

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Str $s = '1ac2.34f0.b1c2') { put MAC-address($s) }
sub MAC-address ($x) { $x.comb(rx:i/<[ a..f 0..9 ]> ** 2/).join(':') }
```

We can do pretty much the same using a global match in [Perl][]:

```perl
#!/usr/bin/env perl
printf "%s\n", MAC_address(shift // '1ac2.34f0.b1c2');
sub MAC_address { join ':', shift =~ m{([a-f0-9]{2})}igmxs }
```

I know... I removed `strict` and `warnings`... please forgive me and
stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#185]: https://theweeklychallenge.org/blog/perl-weekly-challenge-185/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-185/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
