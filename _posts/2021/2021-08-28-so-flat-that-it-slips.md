---
title: So flat that it Slips
type: post
tags: [ rakulang ]
comment: true
date: 2021-08-28 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I'm starting to get a gist about [flat][] and [Slip][] in [Raku][].

Or so I hope.

The documentation is sparse, or at least I personally find it so. This
means that I'm a bit confused by reading around about [flattening][] and
[Slips][], and who knows whatever else I might have read and forgotten.

As my current mental reference I have what follows.

[List][] stuff can be contained in a nested hierarchical way. Example:

```raku
> my $list = (1, (2, 3), (4, (5, 6)))
(1 (2 3) (4 (5 6)))
```

**Flattening** is about *massaging the internals* of a [List][] with
multiple items inside try and remove the hierarchy (if possible).
Example:

```raku
> $list.flat
(1 2 3 4 5 6)
```

**Slipping** is about *removing walls around elements* to let the
internal stuff out. Example:

```raku
> my $foo = (1, 2, 3);
(1 2 3)
> my @bar = $foo   # no slipping, $foo treated singularly
[(1 2 3)]          # @bar has one single element (a list)
> my @bar = |$foo  # slipping, $foo is "expanded"
[1 2 3]            # @bar contains three elements

> my @foo = 1, 2, 3; # one example array
> [1 2 3]
> my @bar = 4, 5, 6; # another example array
[4 5 6]
> my @baz = (@foo, @bar);  # @baz contains two sub-arrays
[[1 2 3] [4 5 6]]
> my @galook = (|@foo, |@bar); # @galook has 6 elements
[1 2 3 4 5 6]
```

Then there is the special case about [flat][], which took me a bit to
understand. I mean... it's explained, it took *me* a bit to understand.

In a nutshell, [flat][] has no power on *itemized* elements, i.e.
sub-parts that have been explicitly put *inside* a container. While a
[List][] usually contains *plain elements* with no container around, we
can force the presence of this container like this (note the leading `$`
in `$(5, 6)`):

```raku
> my $list-with-item = (1, (2, 3), (4, $(5, 6)))
(1 (2 3) (4 (5 6)))
> $list-with-item.flat   # note the final (5, 6)
(1 2 3 4 (5 6))
```

This has the effect of spoiling the party when we try to call [flat][]
on an [Array][], because an [Array][] always *wraps* each element inside
a container. In other words, [Array][]s behave like [List][]s where each
element is *itemized*.

Which leads us to this:
```raku
> my @array = [1, [2, 3], [4, [5, 6]]];
[1 [2 3] [4 [5 6]]]
> @array.flat
(1 [2 3] [4 [5 6]])
```

In this case, we can explicitly turn the thing into a [List][] and then
flatten that, although we don't get the *recursive* behaviour anyway:

```raku
> @foo.List
(1 [2 3] [4 [5 6]])
> @foo.List.flat   # [5, 6] is still there...
(1 2 3 4 [5 6])
```

A possible solution to this (should we need one) is explained in [this
answer in StackOverflow][]. Long story short: avoid nested [Array][]s if
you need to use [flat][], or know how to traverse your hierarchy to do
some flattening.

I hope I got everything I needed to get. Otherwise, I'll continue to use
my *try-check-retry* algorithm, where I try [flat][], then [Slip][],
then [List][] with [flat][], then... *internet search*.

Stay safe and have `-Ofun`!!!

[Raku]: https://www.raku.org
[Perl]: https://www.perl.org
[flat]: https://docs.raku.org/routine/flat
[flattening]: https://docs.raku.org/language/list#Flattening_
[Slip]: https://docs.raku.org/routine/Slip
[Slips]: https://docs.raku.org/language/list#Slips
[List contexts]: https://docs.raku.org/language/list#List_contexts
[contexts | List]: https://docs.raku.org/language/contexts#List
[List]: https://docs.raku.org/type/List
[Array]: https://docs.raku.org/type/Array
[this answer in StackOverflow]: https://stackoverflow.com/a/41649110
