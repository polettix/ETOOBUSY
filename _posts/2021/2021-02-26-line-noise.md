---
title: Line noise
type: post
tags: [ perl, coding ]
comment: true
date: 2021-02-26 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I wrote [Perl][] code that resembles line noise 😅

[Perl][] has been often accused of being incredibly difficult to read,
sometimes even by [Perl][] programmers.

Personally, I've never been bothered too much by this, either because I
have the luck to *not* maintain any [Perl][] code that I didn't spoil
myself, or because it's entirely possible to write perfectly readable
code.

While looking back at a recent post, my eye was caught by this
[write-only][] line:

```perl
map { $_ eq '*' ? '.*' : $_ eq '?' ? '.' : quotemeta($_) } ...
#     \_____ four letters in total ______/ 
```

I find the two close `?` question marks particularly amusing. To be
honest, this is *totally* my fault, because the syntax for the ternary
operator is not specific to [Perl][] and in this case I'm mixing stuff
that is problem specific (like the string with a single question mark)
with it.

Let's rewrite it in a more *readable* way:

```perl
my $star = '*';
my $question_mark = '?';
my $regexp_any_sequence_of_characters = '.*';
my $regexp_any_character = '.';

#...

map {
      $_ eq $star          ? $regexp_any_sequence_of_characters
    : $_ eq $question_mark ? $regexp_any_character
    :                        quotemeta($_)
} ...
```

Seems nicer on the reader, doesn't it?!?

[Perl]: https://www.perl.org/
[write-only]: https://en.wikipedia.org/wiki/Write-only_language
