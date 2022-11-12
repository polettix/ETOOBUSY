---
title: Monkey Patch
type: post
tags: [ perl, mojolicious ]
comment: true
date: 2020-09-27 14:55:01 +0200
mathjax: false
published: true
---

**TL;DR**

> Looking at the internals of [Mojolicious][] is always interesting.

I was taking a look through the [Mojolicious][] distribution, and in
particular to the *Mojo* toolset, when I hit function [`monkey_patch`][]:

```perl
 1 sub monkey_patch {
 2   my ($class, %patch) = @_;
 3   no strict 'refs';
 4   no warnings 'redefine';
 5   *{"${class}::$_"} = set_subname("${class}::$_", $patch{$_}) for keys %patch;
 6 }
```

[Wikipedia][] defines [Monkey Patch][] as follows:

> A monkey patch (also known as "duck punching") is a way for a program
> to extend or modify supporting system software locally (affecting only
> the running instance of the program). 

Think to a class that does not have a specific method, but it would be
*soooo* useful that you eventually add it.

The function is not complicated *per-se*, because it literally just
installs functions with a specific name in the target package, but the
idea to get stuff around and re-assemble them into another place is just
amazing.

The [`monkey_patch`][] function receives the name of the target `$class`
to be extended, as well as key/sub pairs to install in it (line 2).

Line 5 fiddles with the internals of the package `$class`, which is
usually a moderately well guarded place. For this reason, line 3 takes
care to tell `strict` that it's OK to fiddle with `refs` (i.e. we tell
it we are supposed to know what we are doing) and we also ask `warnings`
to close an eye if a function gets re-defined in the `$class` package
(line 4). To some extent, these two lines represent a warning sign that
some magic will happen but it's intentional and for greater good.

Line 5 is the actual installation of the functions. It loops through the
keys provided in input, and at each iteration it installs a sub (that is
`$patch{$_}`).

The *fully qualified name* of the function is what we will be able to
call this function by telling the interpreter where to find the function
exactly, i.e. `$class` in our case. As such, it is just the name of the
class, two colons `::`, and the *bare name* provided in input, that is
the following string:

```perl
"${class}::$_"
```

This name is used in two places within line 5:

- in the left hand side of the assignment, to ask the [Perl][]
  interpreter for the proper *slot* that we want to fiddle with (this is
  done using `*{...}`). This is where lines 3 and 4 came handy;
- in the right hand side, to associate a name to the *possibly
  anonymous* sub that we are setting, via `set_subname`.

So... what's this `set_subname`?!? Why use it instead of just installing
the sub in the symbol table? Because we want to have clarity in stack
traces!

Let's take a look at an example *anonymous sub*:

```shell
$ perl -MCarp=confess -e 'my $x = sub { confess "inside a sub" }; $x->()'
inside a sub at -e line 1.
	main::__ANON__() called at -e line 1
```

The [Perl][] interpreter does not know how this *anonymous* sub is
called, so it calls it... `__ANON__`. This can be admittedly ugly and
somehow obscure if you're doing some troubleshooting.

Now... enter `set_subname` from [Sub::Util][]:

```shell
$ perl -MCarp=confess -MSub::Util=set_subname -e '
    my $x = sub { confess "inside a sub" };
    set_subname(my_hazardous_sub => $x)->();'
inside a sub at -e line 2.
	main::my_hazardous_sub() called at -e line 3
```

This is *much* better, isn't it?!?

So... this little [`monkey_patch`][] can be very handy when used with
care, and as an added bonus I discovered about `set_subname` 🤩


[Wikipedia]: https://en.wikipedia.org/wiki/
[Monkey Patch]: https://en.wikipedia.org/wiki/Monkey_patch
[`monkey_patch`]: https://metacpan.org/source/SRI/Mojolicious-8.59/lib/Mojo/Util.pm#L181
[Sub::Util]: https://metacpan.org/pod/Sub::Util
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Perl]: https://www.perl.org/
