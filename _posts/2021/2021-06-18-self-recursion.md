---
title: More robust self-recursion
type: post
tags: [ perl ]
comment: true
date: 2021-06-18 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I discovered a more robust way to recurse in [Perl][].

I usually avoid coding recursive functions if I can, not because of any
scientific reason (I have none) but because when I studied my first
course in computer science it sort-of stuck with me that iterations
should be more efficient. Pair this with the other (personally)
unsubstantiated vague notion that [Perl][] sub calling is slow... and
voilà, we have the perfect prejudice.

Anyway.

I sometimes rename subs, because I find a better name, or do some
refactoring, or whatever other reason. Sometimes I even try to code an
alternative form of a previous sub, so I copy/paste to keep them both.

This is usually not a problem... except that it's *so* easy to forget to
do the renaming in the recursion call in a recursive function.

This is why I was pleasantly surprised when I (re)discovered that, as of
`perl` 5.16, we have [the `__SUB__` token][docs] to help us.

Consider the following:

```perl
sub countdown ($n) {
    return if $n < 0;
    say $n;
    return countdown($n - 1);
}
```

OK it's pretty lame, but it prints the countdown from the provided input
down to 0, included. Now I rename it to make it more readable:

```perl
sub countdown_from ($n) {
    return if $n < 0;
    say $n;
    return countdown($n - 1);
}
```

and **boom**, the `return countdown($n - 1)` is an error from now on.

The `__SUB__` token gives us a reference to the function we are
currently in. Which can be very helpful in my case, right?

```perl
sub countdown_from ($n) {
    return if $n < 0;
    say $n;
    return __SUB__->($n - 1);
}
```

From now on, whatever name I give to the function... it will *just
work*. Yay!

[Perl]: https://www.perl.org/
[docs]: https://metacpan.org/pod/feature#The-'current_sub'-feature
