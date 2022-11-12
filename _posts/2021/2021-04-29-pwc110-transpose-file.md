---
title: PWC110 - Transpose File
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-04-29 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#110][].
> Enjoy!

# The challenge

> You are given a text file.
>
> Write a script to transpose the contents of the given file.
>
> Input File
>
>     name,age,sex
>     Mohammad,45,m
>     Joe,20,m
>     Julie,35,f
>     Cristina,10,f
>
> Output:
> 
>     name,Mohammad,Joe,Julie,Cristina
>     age,45,20,35,10
>     sex,m,m,f,f

# The questions

I guess it was virtually *impossible* to guess that the input file is a
CSV-ish file and that the transposition has to be done on its *logical*
columns without looking at the example.

We'll take the *really* lazy route here and assume that:

- commas are *always* the separator, and
- commas do not appear in the text, and
- there is no other special character, no quotes, etc.

Pretty lazy, uh? Well, my excuse is that the *next level* would be to
grab some [ready-made CSV module from CPAN][cpan] and use it instead of
rolling my own... which would be just as lazy (in a good way).


# The solution

I like it when I can reuse stuff, so here I'm reusing the "give me a
filehandle or a file, and I'll do what's needed" approach I took in the
other puzzle of this challenge:

```perl
sub transpose_file ($f) {
   $f = ref($f)     ? $f
      : ($f eq '-') ? \*STDIN
      :               do { open my $h, '<', $f or die "$!\n"; $h };

   # ...
```

For the transposition, we will first read all lines in memory, doing the
*parsing* on the fly (i.e. getting the fields separated by commas):

```perl
   my @lines = map { chomp; [ split m{,}mxs ] } <$f>;
```

Next, we will do an indefinite loop to get one item out of these lines,
defaulting to an empty slot. This allows us to cope with lines that
might be longer or shorter (in terms of fields that they hold):

```perl
   while ('necessary') {
      my $g = 0;
      my @t = map { $g = 1 if $_->@*; shift($_->@*) || '' } @lines;
      last unless $g;
      say join ',', @t;
   }
```

The *column to row grabbing* is done through a `map`, although it
*breaks* the usual pattern where you are not supposed to generate any
side effect in a `map`. This time we keep a flag variable `$g` to check
if we **g**ot any item in a specific pass; this is our check to see if
we arrived at the end of the iteration.

If we indeed get any item in a pass of the `map`, `$g` will be set to
`1` and we will print the row (well, the *column*!) to move on to the
next iteration.

The whole program, for the interested ones:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub transpose_file ($f) {
   $f = ref($f)     ? $f
      : ($f eq '-') ? \*STDIN
      :               do { open my $h, '<', $f or die "$!\n"; $h };
   my @lines = map { chomp; [ split m{,}mxs ] } <$f>;
   while ('necessary') {
      my $g = 0;
      my @t = map { $g = 1 if $_->@*; shift($_->@*) || '' } @lines;
      last unless $g;
      say join ',', @t;
   }
   return;
}

my $f = shift // do {
   my $input = <<'END';
name,age,sex
Mohammad,45,m
Joe,20,m
Julie,35,f
Cristina,10,f
END
   open my $fh, '<', \$input;
   $fh;
};

transpose_file($f);
```

Stay safe folks!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#110]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-110/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-110/#TASK2
[Perl]: https://www.perl.org/
[cpan]: https://metacpan.org/search?size=500&q=csv
