---
title: 'Syntax checking - or how to lose against a >'
type: post
tags: [ perl ]
comment: true
date: 2023-05-16 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I wasted way too much time debugging a silly syntax error.

To make a long story short, here's an equivalent of what I was writing:

```perl
my $foo => Some::Class->new;
say defined($foo) ? 'foo is defined' ! 'foo is NOT defined';
```

Easy to spot now that you know that there's something fishy around, uh?

If you didn't spot it already, there's a stray `>` character that totally
changes the meaning of the `=` sign immediately before, thwarting the
assignment to `$foo`.

Result? `$foo` remains unassigned and `undef`.

I could only figure out this *after* writing a brand new line like the
following, and putting it close to the original

```perl
my $bar =  Some::Class->new;
my $foo => Some::Class->new;
```

*Of course* now, with the right alignment and puntuation, the solution
appears trivial. **Now** being the key concept.

Stay safe and keep both eyes open!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
