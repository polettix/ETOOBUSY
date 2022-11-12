---
title: 'Raku community answered to shift || 5'
type: post
tags: [ rakulang ]
comment: true
date: 2021-07-26 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> What's the [Raku][] equivalent of `shift || 5` in [Perl][]? The
> [Raku][] community answered.

In previous post [Brute forcing "The monkey and the coconuts"][] I did
an observation where I preferred the *[Perl][] way* of doing one thing:

> Getting the input number of sailors from the command line is somehow
> *worse* though:
>
>     my $sailors = @*ARGS ?? @*ARGS[0].Int !! 5;
>
> I like [Perl][] better in this case:
>
>     my $sailors = shift || 5;
>
> **(Of course I hope someone will point out how to express this in
> [Raku][] 😋)**

My wish was kindkly fulfilled by [gfldex][]:

>      my $sailors = shift || 5;
> 
> literally translates to:
> 
>      my Int() $sailors = @*ARGS.shift // 5;
> 
> The coercer can coerce to many things ofc, as long as they can be
> coerced from a string. Like the following:
> 
>      my Date() $when = @*ARGS.shift // now;
> 
> That works because `infix:<//>` does a boolean check and then skips
> over the `Failure` when `@*ARGS` is already empty. In [Raku][] we do
> have types and exceptions. So we need the tools to handle them.

Well, certainly thanks!

And, of course, something more to study.

I was intrigued by the usage of `Int()` where I would have expected
`Int` actually. It turns out that they're not the same and... `Int()` is
correct, at least in this case.

Inputs in `@*ARGS` are strings (type/class `Str`), so we need to
**coerce** them into integers (type/class `Int`). If we omit the
parentheses we get an error:

```raku
my Int $integer = '12';
# OUTPUT: Type check failed in assignment to $integer; expected Int but
#         got Str ("12")
```

This is because `Int` tells [Raku][] that we *demand* to receive an
`Int`, and whatever is not compatible will have to be thrown away.
(`IntStr` would still be OK, but it's not what ends up in `@*ARGs`,
sorry!).

On the other hand, it seems that the version with the parentheses asks
[Raku][] to do the *coercion*, if possible:

```raku
my Int() $integer = '12';
put $integer.^name;
# OUTPUT: Int
```

while still complaining when it's *not* possible:

```raku
my Int() $integer = 'galook';
# OUTPUT: Cannot convert string to number: ...
```

Finding documentation about the usage of `Int()` proved surprisingly
difficult for me, although I later [understood why][].

Again, [gfldex][] came to the rescue, kindly sharing further details:

- Type coercion in variable declation follows the [same rules as in
  Signature][];
- a detailed description of how to provide coercers [can be found
  here][];
- coercion is very useful, as [gfldex's blog shows][].

So much stuff to read now!!!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Brute forcing "The monkey and the coconuts"]: {{ '/2021/07/24/monkey-and-coconuts/' | prepend: site.baseurl }}
[gfldex]: https://gfldex.wordpress.com/
[same rules as in Signature]: https://docs.raku.org/type/Signature#Coercion_type
[can be found here]: https://vrurg.github.io/2020/11/16/Report-On-New-Coercions
[gfldex's blog shows]: https://gfldex.wordpress.com/?s=coerce
[understood why]: https://github.com/Raku/doc/issues/3807
