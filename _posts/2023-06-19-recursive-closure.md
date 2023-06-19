---
title: Recursive closure
type: post
tags: [ perl ]
comment: true
date: 2023-06-19 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A small technique in [Perl][] that I sometimes use.

I was [extending validns][validns] some days ago, when I realized that what
I had in mind could be implemented quite easily with a recursive function.
So what's the problem? Just make sure to use [More robust self-recursion][],
and you're done, right?

Well, not so fast. I was collecting some data along the way, which usually
means adding some *more* parameters to the function call, passing down a
reference to whatever data structure I want to populate/use down the road.

Except that it's a bit clunky and not ideal while prototyping and figuring
out how things should go; having the possibility to just write a `my
%foobar` and use it is so much easier.

Sometimes, then, I turn to coding a *recursive closure*. It's a function
*inside* the main function, which closes on some variables (hence the
*closure* part) and does recursion over *itself* (hence the *recursive*).

Something like this admittedly contrived example:

```perl
sub outer_not_recursive ($n) {
    my @factorials = (1);
    sub ($i) {  # inner, recursive closure
        return if $i > $n;
        push @factorials, $factorials[-1] * $i;
        __SUB__->(++$i);
    }->(1);
    return $factorials[$n];
}
```

The closed-on variables (`$n`, `@factorials`) are there to be used directly,
while `__SUB__` takes excellent care of doing the recursion without the need
to write anything strange and/or unreadable.

Cheers!

[Perl]: https://www.perl.org/
[validns]: https://codeberg.org/polettix/validns/src/commit/f65ae95babecbd2c57fec6c9bd87b6af2a6be5ae/lib/ValiDNS.pm#L327
[More robust self-recursion]: {{ '/2021/06/18/self-recursion/' | prepend: site.baseurl }}
