---
title: PWC096 - Reverse Words
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-01-20 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#096][]. Enjoy!

# The challenge

> You are given a string `$S`.
>
> Write a script to reverse the order of words in the given string. The
> string may contain leading/trailing spaces. The string may have more
> than one space between words in the string. Print the result without
> leading/trailing spaces and there should be only one space between
> words.

# The questions

This is the typical challenge that takes nothing to solve for 80% of the
cases (including 100% of the examples!) but takes the rest of your life
to solve properly. Well, even to *define* properly.

Just like messing with dates and times, you know.

Anyway, the big elephant in the room is what we define to be a *word*.
In normal text we find words (like those things that have a definition
in a dictionary), spaces and punctuation marks, like commans, full
stops, colons etc.

What should we do with the punctuation marks? Consider them as part of
the word they are close to (no spaces inside)? Consider them as some
*structure* that we have to preserve? Remove them completely?

Moreover... sometimes punctuation marks delimit some text, e.g. when you
use double quotes around a sentence. should we preserve that structure?

Other times punctuation marks indicate a *loss* of something. E.g. an
apostrophe might indicate that we're dropping a letter or more to ease faster
talking (like *I'll* instead of *I will*) - how should we treat that?

Long story short, we will consider a *word* any sequence of *non-spacing
characters*... for whatever [Perl][] considers to be a spacing
character. And get on with our life!

# The solution

This challenge (well, the *easy* formulation of the challenge, at
least) cries for a compact, cryptic solution because it's one line and
it does not take too much to understand anyway:

```perl
sub reverse_words ($S) {
   join(' ', reverse split m{\s+}mxs, $S) =~ s{\s+\z}{}rmxs;
}
```

At its heart, it [split][]s the input string using any sequence of one
or more spacing characters, so we get back a list of non-spacing
*items*. These items are *usually* non-empty strings (more on this
shortly).

Using [reverse][] we can... *reverse* the list, just like we're asked to
do. Using [join][] we merge the list back into a string, this time
making sure to insert exactly *one* space between adjacent *items*.

One side effect of the [split][] is that an *initial* sequence of spaces
gives rise to an initial item that is actually an empty string. As a
consequence, the resulting string will contain a trailing space in this
case.

For this reason, we make sure to remove that trailing space (if present)
with the substitution `s{\s+\z}{}rmxs`; here we're leveraging the
regular expression modifier `r` to make sure that a *copy* is returned
(as opposed to modifying the input object in-place); this copy doubles
down as our result value.

This is really it! The whole program, if you're curious or just fond of
copy-and-paste:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub reverse_words ($S) {
   join(' ', reverse split m{\s+}mxs, $S) =~ s{\s+\z}{}rmxs;
}

my $input = join(' ', @ARGV)
   || '    Perl and   Raku are  part of the same family  ';
say '<', reverse_words($input), '>';
```

Have fun... safely!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#096]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-096/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-096/#TASK1
[Perl]: https://www.perl.org/
[split]: https://perldoc.pl/functions/split
[reverse]: https://perldoc.pl/functions/reverse
[join]: https://perldoc.pl/functions/join
