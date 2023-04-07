---
title: Modulabile
type: post
tags: [ perl ]
comment: true
date: 2023-03-20 06:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I want to tack a new meaning to the Italian word **Modulabile**.

*Modulabile* is an Italian word that more or less means *adjustable*. I'd
like to attach a new meaning in a [Perl][] context, though, and in
particular *of a module that can be easily used in a one-liner*.

We already know about [Modulino][]s: a [Perl][] module that doubles down as
an executable, if needed.

Now, with a *Modulabile* I'd like to do something much in that spirit, but
going a bit farther. Where modulinos are normally created as an evolution
from programs to make them more easily testable, with a *Modulabile* I'd
like to add an easy way to use a module from the command line, or at least
its most obvious functionality.

The concept is by no means new or invented by me. The most egregious example
*that I personally know of* is the [ojo][] module, that allows placing a
catch `-Mojo` command line option to import a bunch of one-letter-long
functions to do all sorts of wonders with [Mojolicious][]. From the
SYNOPSIS:

```shell
$ perl -Mojo -E 'say g("mojolicious.org")->dom->at("title")->text'
```

This way of having modules that can be also easily called as programs
*without the need to know where they have been installed* fascinates me. It
make the *module* somehow *able* to be run, hence the name by merging the
two words.

As an example, in recent module [Validate::CodiceFiscale][] I added this
function, which can also be imported:

```perl
sub r (@args) {
   @args = @ARGV unless @args;
   my $i = 0;
   my $n = 0;
   for my $cf (@ARGV) {
      if (my $errors = validate_cf($cf)) {
         say "$i not ok - " . join(', ', $errors->@*);
         ++$n;
      }
      else {
         say "$i ok - $cf";
      }
      ++$i;
   } ## end for my $cf (@ARGV)
   return $n ? 1 : 0;
} ## end sub r
```

The short name makes it easy to import it from the command line: just use
option `-M` with the addition of two characters, i.e.
`-MValidate::CodiceFiscale=r`.

The way it takes arguments, defaulting to what comes from the command line
itself, makes it *extremely* easy to run the function. All in all, it's
possible to do validation of a few strings on the command line like this:

```shell
perl -MValidate::CodiceFiscale=r -er "$string1" "$string2" ...
```

I was a bit surprised that the `-er` part works, I initially thought I would
have had to put it like this:

```
perl -M... -e 'r()' ...
```

or something similar. I quickly discovered that, having imported function
`r`, I could do away with the round parentheses and quotation marks, so this
would work as well:

```
perl -M... -e r ...
```

Then I just tried to remove the space, and it worked too!

There are many times when the functions in a module are better imported and
used in a *full* program; other times, though, they can come handy from the
command line, so why not enrich our module and make it a... *modulabile*?

Cheers!

[Perl]: https://www.perl.org/
[Modulino]: https://gitlab.com/polettix/notechs/-/snippets/1868370
[ojo]: https://metacpan.org/pod/ojo
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Validate::CodiceFiscale]: https://metacpan.org/pod/Validate::CodiceFiscale
