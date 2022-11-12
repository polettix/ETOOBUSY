---
title: PWC105 - The Name Game
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-03-25 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#105][].
> Enjoy!

# The challenge

> You are given a `$name`. Write a script to display the lyrics to the
> Shirley Ellis song `The Name Game`. Please checkout the [wiki page][] for
> more information.

# The questions

There's a question I don't dare to ask: *what to do with names where the
stress falls on a syllable after the first*? I'm too scared of the answer,
which would involve dropping a full syllable from the beginning of the name,
with all due repercussions (like... having a database or all names and their
division into syllables). No thanks.

Another question would be regarding names that are not expressed in the
latin alphabeth. Or what are the vocal sounds (I'm assuming that `y`
applies). I mean, there's a whole trains of books to read and I don't want
to get started. Thanks.

I'll play it safe with the basic algorithm and names written in the latin
alphabeth. I'll also assume that using the lowercasing operator `lc` does
its job properly, which I vaguely remember not to be the general case. So
again, I'll just assume and not ask... thanks.

# The solution

With all these restrictions, I'm bound to provide a minimal solution:

```perl
sub the_name_game ($name) {
   my ($first, $Y) = $name =~ m{\A([^aeiouy]?)(.*)}mxs;
   $first = lc $first;
   return join "\n",
      "$name, $name, bo-" . ($first eq 'b' ? $Y : "b$Y"),
      "Bonana-fanna fo-"  . ($first eq 'f' ? $Y : "f$Y"),
      "Fee fi mo-"        . ($first eq 'm' ? $Y : "m$Y"),
      "$name!";
}
```

Not much to say about this... it's more or less a straightforward
application of the algorithm provided in the [wiki page][].

Should you be curious, here's the full program:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub the_name_game ($name) {
   my ($first, $Y) = $name =~ m{\A([^aeiouy]?)(.*)}mxs;
   $first = lc $first;
   return join "\n",
      "$name, $name, bo-" . ($first eq 'b' ? $Y : "b$Y"),
      "Bonana-fanna fo-"  . ($first eq 'f' ? $Y : "f$Y"),
      "Fee fi mo-"        . ($first eq 'm' ? $Y : "m$Y"),
      "$name!";
}

my $n = shift || 'Katie';
say the_name_game($n);
```

Stays warm and safe!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#105]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-105/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-105/#TASK2
[Perl]: https://www.perl.org/
[wiki page]: https://en.wikipedia.org/wiki/The_Name_Game
