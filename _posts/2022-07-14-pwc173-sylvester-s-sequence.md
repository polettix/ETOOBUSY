---
title: "PWC173 - Sylvester's Sequence"
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-07-14 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#173][].
> Enjoy!

# The challenge

> Write a script to generate first `10 members` of `Sylvester's
> sequence`. For more informations, please refer to the [wikipedia
> page][].
>
> **Output**
>
>     2
>     3
>     7
>     43
>     1807
>     3263443
>     10650056950807
>     113423713055421844361000443
>     12864938683278671740537145998360961546653259485195807
>     165506647324519964198468195444439180017513152706377497841851388766535868639572406808911988131737645185443

# The questions

Where does [manwar][] take inspiration for all these challenges?

# The solution

I don't know why, when there are challenges about generating sequences
there are two different clicking things in my head:

- the [Perl][] personality goes for iterators;
- the [Raku][] personality goes for classes.

Go figure.

This time was no exception, so here we get the [Perl][] thing:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use Math::BigInt;

my $it = sylvester_sequence_it();
say $it->() for 1 .. shift // 10;

sub sylvester_sequence_it {
   my $n;
   return sub { $n = $n ? 1 + $n * ($n - 1) : Math::BigInt->new(2) }
}
```

We have to use [Math::BigInt][] even for the number of elements asked by
the challenge, which is unusual but anyway welcome. There are not that
many calculations to do, so the performance toll is negligible.

[Raku][] is different and supports your-memory-is-the-limit sizes from
the start:

```raku
#!/usr/bin/env raku
use v6;

class sylvester-sequence { ... };
sub MAIN (Int:D $count = 10) {
   my $ssq = sylvester-sequence.new();
   put $ssq.next for 1 .. $count;
}

class sylvester-sequence {
   has $!n;
   method next { $!n = $!n ?? 1 + $!n * ($!n - 1) !! 2 }
}
```

In both cases I went for taking the overhead of a boolean check
*instead* of adopting a different solution, like cache-and-calculate:

```
my $retval = $n;
$n = 1 + $n * ($n - 1);
return $retval;
```

Or, more succintly:

```
((my $retval, $n) = ($n, 1 + $n * ($n - 1)))[0]
```

Well, first the latter succint alternative sucks because it's unreadable
and I haven't even tried it; second I don't really like pre-calculating
the next value, it's a little pet-peeve in which I feel like I'm wasting
resources calculating at least one value that I'm not going to use.

Anybody knows a good psycologist? A really good one please?

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#173]: https://theweeklychallenge.org/blog/perl-weekly-challenge-173/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-173/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[wikipedia page]: https://en.wikipedia.org/wiki/Sylvester%27s_sequence
[manwar]: http://manwar.org/
