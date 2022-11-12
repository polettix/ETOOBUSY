---
title: PWC090 - DNA Sequence
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-12-11 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#090][]. Enjoy!

# The challenge

> DNA is a long, chainlike molecule which has two strands twisted into a
> double helix. The two strands are made up of simpler molecules called
> nucleotides. Each nucleotide is composed of one of the four
> nitrogen-containing nucleobases cytosine (C), guanine (G), adenine (A) and
> thymine (T).
>
> You are given DNA sequence,
> `GTAAACCCCTTTTCATTTAGACAGATCGACTCCTTATCCATTCTCAGAGATGTGTTGCTGGTCGCCG`.
>
> Write a script to print nucleiobase count in the given DNA sequence. Also
> print the complementary sequence where Thymine (T) on one strand is always
> facing an adenine (A) and vice versa; guanine (G) is always facing a
> cytosine (C) and vice versa.
>
> To get the complementary sequence use the following mapping:
>
>     T => A
>     A => T
>     G => C
>     C => G

# The questions

This challenge left me a bit puzzled for a couple of reasons.

One is that it seems that there's one fixed input only. Well, I'll assume
that we need to do something general.

The other one is that there's no clear indication as to the expected output
format. Which is in line with the easy-going style of this challenge (and I
like it very much, don't get me wrong!) but a bit at odds with the *lack of
an example*. I can only guess that the author had other things to do,
like... ehrm... add my previous contribution to the [Perl Weekly
Challenge][]. Blame that on me 😅

# The solution

First, a confession.

> Forgive me **siblings**, because I have string-`eval`-ed.

I mean, there was a beautiful, juicy apple with `tr` stamped on it, and I
couldn't resist using it. But this led me to `eval`-ing, in the worst
possible form: *the string `eval`*.

## A bit of background

If you're puzzled at this point, I owe you an explanation.

The [transliteration operator][] (`tr` or `y` for friends) is a handy
operator that transforms letters in a string into other letters (or
nothing). This is basically what *transliteration* means.

As an added bonus, in certain cases it also tells us how many
transliterations were done.

So... can you see it? We can use this hammer to hit all of our nails:

- want to count the number of nucleobases? Transliterate them and get the
  count!
- want to generate the complementary of the input sequence? Transliterate it
  according to the mapping!

So... this challenge is *really screaming* for `tr`.

## The complementary string is easy

Using the [transliteration operator][] for generating the complementary is
easy, just provide a sequence of letters to be substituted, and the sequence
of substitutes:

```perl
my $complementary = $original_sequence =~ tr{ACGT}{TGCA}r;
```

The syntax means that any single character in sequence `ACGT` has to be
transliterated in the corresponding character in sequence `TGCA`.

We're also adding the `/r` modifier, so that we keep variable
`$original_sequence` unchanged and generate a copy instead, which will end
up in `$complementary`.

This was the easy part, still on the bright side.

## Let's talk about counting those nucleobases...

Counting all occurrences of `A` is straightforward: we can just substitute
all `A`s (deleting them is OK in this case) and collect the number of
substitutions by calling `tr` in *scalar context*:

```perl
my $n_A = $original_sequence =~ tr{A}{}d;
```

The `/d` deletes the `A` - it's OK for this toy. The scalar context
evaluation, as anticipated, provides the number of substitutions back, which
is the same as the number of `A`s in the string. Nifty!

Now we have to repeat this for the other nucleobases. Which brings us to a
little bump in the path: should we just copy-and-paste the code for `$n_A`
into similar lines for `$n_C`, `$n_G`, and `$n_T`?
  
This would break the *golden rule of refactoring*! So we should instead aim
for a more generic way of doing this. Something *like* this:

```perl
my %count_for = map {
    $_ => scalar $original_sequence =~ tr{$_}{}d 
} qw< A C G T >;
```

Easy, right? We iterate over the four different nucleobases, and call `tr`
for each of them. Mission accomplished, let's chill out now! Beer anyone? A
Ginger Ale maybe?

Well... *not so fast*!

## The *problem* with the [transliteration operator][]

Fact is that our code in the last subsection *does not work*.

With the [transliteration operator][], letters are transliterated literally.

Hu?!? Well, I mean that `$_` is *not* considered as the *topic variable*,
but a sequence of two literal characters, i.e. `$` followed by `_`. Which is
clearly written in the documentation, by the way:

> But there is never any variable interpolation, so `$` and `@` are always
> treated as literals.

So we are back to the bloated approach:

```perl
my $n_A = $original_sequence =~ tr{A}{}d;
my $n_C = $original_sequence =~ tr{C}{}d;
my $n_G = $original_sequence =~ tr{G}{}d;
my $n_T = $original_sequence =~ tr{T}{}d;
```

Well... *not so fast*!

## Choose your sin

There are a couple of ways to fix the loop-based approach to this counting
problem.

The cleaner way is probably to recognize that the [substitution operator][]
helps doing the counting as well, so the following *does* work indeed:

```perl
my %count_for = map {
    $_ => scalar $original_sequence =~ s{$_}{}g
} qw< A C G T >;
```

Note that we have to specify the `/g` modifier to take into account *all*
candidates for the substitution.

But heck! What party is this for celebrating the [transliteration
operator][], if we then use another one?!? This is a sin and a shame!

Why not err to the *dark side of the [Perl][] hacker*?!? Come on... a
*ssssss*mall `eval` will cau*ssssssss*e no harm... it'*sssssssss* there for a
purpo*ssssssss*e...

OK, we can do this instead:

```perl
my %count_for = map {
    $_ => eval "scalar \$s =~ tr{$_}{}d"
} qw< A C G T >;
```

At each iterator, the string is interpolated to generate a valid `tr`
invocation. As an example, if `$_` is equal to `C`, the resulting string is
`scalar $s =~ tr{C}{}d`, which is exactly what we need to do the *counting
transliteration* for nucleobase `C`.

The `eval` here is to... evaluate this string within the program. And save
[`tr`][transliteration operator]'s party and birthday present!


# The whole thing

In full disclosure of my sins, here is my code for this week's challenge, so
that you can learn from *my* errors:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub dna_sequence ($s) {
   my $complementary = $s =~ tr{ACGT}{TGCA}r;
   my %cf = map { $_ => eval "scalar \$s =~ tr{$_}{}d" } qw< A C G T >;
   return (\%cf, $complementary);
}

my $default =
  'GTAAACCCCTTTTCATTTAGACAGATCGACTCCTTATCCATTCTCAGAGATGTGTTGCTGGTCGCCG';
my $sequence = shift || $default;
my ($cf, $complementary) = dna_sequence($sequence);

$|++;
say {*STDERR} $sequence;
say {*STDOUT} $complementary;
say {*STDOUT} "A<$cf->{A}> C<$cf->{C}> G<$cf->{G}> T<$cf->{T}>";
```

So long... I'll wave you from hell!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#090]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-090/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-090/#TASK1
[Perl]: https://www.perl.org/
[transliteration operator]: https://perldoc.perl.org/perlop#tr/SEARCHLIST/REPLACEMENTLIST/cdsr
[substitution operator]: https://perldoc.perl.org/perlop#s/PATTERN/REPLACEMENT/msixpodualngcer
