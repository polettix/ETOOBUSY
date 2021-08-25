---
title: Pipe the hash through the call
type: post
tags: [ rakulang ]
comment: true
date: 2021-08-30 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Use `|%hash` to pass `%hash` as named arguments in a sub/method call.

Which, I have to admit, was not a secret.

Fact is that, in [Perl][], there is no core mechanism to cope with named
arguments. Which has always been fine for me, as I happily used hashes
(or references thereof) to gain the same effect, assuming the risk of
getting keys wrong or coding some form of parameters validation.

On the other hand, in [Raku][] they listened to the needs of the
programmers and put a complete and powerful way of managing
[signatures][], including explicit support for named arguments. So this
basically work:

```raku
sub foo (:$bar) { $bar.put }
foo(bar => 'Hello, World!');
```

So far so good.

One thing that I did in [Perl][], though, was collecting arguments for a
sub call in a hash, then use the hash as arguments for the call.
Something like this:

```perl
sub foo { my %args = @_; say $args{bar} }
my %args = (bar => 'Hello, Perl!');
foo(%args);
```


This is not possible in [Raku][], though, because there is no turning of
the hash into a list of arguments and it is passed as a *positional*
argument instead. So this equivalent:

```raku
sub foo (:$bar) { $bar.put }
my %hash = (bar => 'Hello, People!');
foo(%hash);
```

produces an error:

```
Too many positionals passed; expected 0 arguments but got 1
```

The solution? Use a [pipe operator `|`][operator]:

```raku
sub foo (:$bar) { $bar.put }
my %hash = (bar => 'Hello, Folks!');
foo(|%hash);
# OUTPUT: «Hello, Folks!␤»
```

From [the docs][operator]:

> Inside argument list `Positional`s are turned into positional
> arguments and `Associative`s are turned into named arguments.

Exactly what I needed, thanks!

[Perl]: https://www.perl.org
[Raku]: https://www.raku.org
[Signature]: https://docs.raku.org/type/Signature
[signatures]: https://docs.raku.org/language/functions#Signatures
[operator]: https://docs.raku.org/routine/|
