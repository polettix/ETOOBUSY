---
title: PWC108 - Locate Memory
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-04-14 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#108][]. Enjoy!

# The challenge

> Write a script to declare a variable or constant and print its
> location in the memory.

# The questions

I like [Perl][] and I'll take this to be a [Perl][]-only question, but
this might not be the case, so a few questions might be:

- is this about [Perl][]?
- should the program be written in [Perl][], but based on some
  executable that is not the program itself?

I can only *guess* that the second can be done by someone, not by me. If
you're looking for that person... goodbye, it's been a pleasure and
thanks for the coffee.

Another question is how constrained the environment is. I mean, we all
tend to give CORE modules for granted, but:

- `perl` in some Linux distributions might break this assumption;
- some modules entered CORE only at a certain point in time (e.g.
  `Scalar::Util was first released with perl v5.7.3`).

So a question might be *can we assume a sane `perl` released in the
latest 10 years?.

Last questions relate to the linguistic aspect of the challenge:

- are we allowed to declare more than one variable or constant?
    - I guess so, because declaring two variables still cover the
      requirement of declaring *a variable*;
- can we declare *both* variables and constants?
    - I guess so, because the *or* can be interpreted as being
      *inclusive* rather than *exclusive* (this is also consistent with
      the usual meaning of `||` and `or` in most programming languages).

# The solution

This will be boring but still... the most robust thing I can think of:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;

use Scalar::Util 'refaddr';
sub locate_memory { refaddr(ref($_[0]) ? $_[0] : \$_[0]) }

my $whatever = 42;
say locate_memory($whatever);
say locate_memory(\$whatever);
say locate_memory(\\$whatever);
say locate_memory(42);
say locate_memory(42);
say locate_memory(bless {}, 'Whatever');
```

Yes, the `refaddr` function in [Scalar::Util][] is actually all that we
need here. There's a couple of twists that might use some explanation:

- no *signatures* this time, we're operating directly over `$_[0]`. This
  is important, because `$_[0]` is an *alias* to the original
  variable/constant, not a copy. This means that we will be operating
  exactly on the thingie we have declared;
- we take a reference to the variable/constant unless we're passed one
  as input. This is why we expect the first two `say` lines to actually
  print out the same value. This is under the assumption that if you
  pass a reference you're generally interested into the *referenced*
  thing, not the reference itself; you can still grab information on the
  reference by passing... a *reference* to it (e.g. see the third `say`
  for an example).

A couple of example runs:

```
$ perl perl/ch-1.pl
94760002921544
94760002921544
94760002921568
94760002920680
94760002752880

$ perl perl/ch-1.pl 
94304258147400
94304258147400
94304257978736
94304258147424
94304258146536
94304257978736
```

As expected, the first two lines in both runs show the same value; all
other ones are different. It's also worth noting that two different runs
yield different values: this, I *suppose*, is thanks to some
randomization in the placement of stuff in memory to make it harder some
kind of attack. Or maybe it's just random randomness.

Stay safe!


[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#108]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-108/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-108/#TASK1
[Perl]: https://www.perl.org/
[Scalar::Util]: https://metacpan.org/pod/Scalar::Util
