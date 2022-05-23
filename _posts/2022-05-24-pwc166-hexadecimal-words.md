---
title: PWC166 - Hexadecimal Words
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-05-24 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#66][]. Enjoy!

# The challenge

> As an old systems programmer, whenever I needed to come up with a
> 32-bit number, I would reach for the tired old examples like
> `0xDeadBeef` and `0xC0dedBad`. I want more!
> 
> Write a program that will read from a dictionary and find **2- to
> 8-letter words** that can be “spelled” in hexadecimal, *with* the
> addition of the following letter substitutions:
> 
> - `o` ⟶ `0` (e.g., `0xf00d` = “**food**”)
> - `l` ⟶ `1`
> - `i` ⟶ `1`
> - `s` ⟶ `5`
> - `t` ⟶ `7`
> 
> You can use your own dictionary or you can simply open
> `../../../data/dictionary.txt` (relative to your script’s location in
> our [GitHub repository][]) to access the dictionary of common words
> from [Week #161][].
> 
> **Optional Extras (for an `0xAddedFee`, of course!)**
> 
> 1. Limit the number of “special” letter substitutions in any one
>    result to keep that result at least somewhat comprehensible.
>    (`0x51105010` is an actual example from my sample solution you may
>    wish to avoid!)
> 2. Find *phrases* of words that total 8 characters in length (e.g.,
>    `0xFee1Face`), rather than just individual words.

# The questions

Is it ok to only address one of the two extras? Implementing the search
for 8-characters phrases is an interesting challenge... *by itself* 🙄

# The solution

Blunt and to the point:

- take all words from the dictionary
- transform into hexadecimal words, or pass if not possible
- print

The transformation considers each character at a time:

- letters from `a` to `f` are OK and passed as-is
- letters that can turn into digits are transformed, unless too many
  transformations already occurred in which case we bail out
- other letters make us bail out.

[Raku][] first:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int :$max-subs = 8) {
   my $dict = $*PROGRAM.parent.child('../../../data/dictionary.txt');
   put '0x' ~ $_ for hexadecimal-words-from($dict, :$max-subs);
}

sub hexadecimal-words-from($file, :$max-subs) {
   $file.IO.lines.map({hexadecimal-word($_, :$max-subs)}).grep({.defined});
}

sub hexadecimal-word($candidate, :$max-subs is copy = 8) {
   state %HEX-LETTERS = set('abcdef'.comb);
   state %DIGIT-FOR = < o 0 i 1 l 1 s 5 t 7 >;
   my @chars = gather for $candidate.lc.comb -> $char {
      if $char ∈ %HEX-LETTERS { take $char; next }
      return unless %DIGIT-FOR{$char}:exists;
      return if --$max-subs < 0;
      take %DIGIT-FOR{$char};
   }
   return @chars.join('');
}
```

I like the path handling and I/O stuff out of the box. Really.

I *don't* like that `return` gives back `Nil` and needs filtering with
`grep`. There's probably a better way to do this, but it would have felt
*DWIMMY*.

[Perl][] now:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use File::Spec::Functions qw< splitpath splitdir catdir catpath >;

my $max_subs = shift // 8;

my ($v, $dirs, $file) = splitpath(__FILE__);
$dirs = catdir(splitdir($dirs), split m{/}mxs, '../../../data');
$file = catpath($v, $dirs, 'dictionary.txt');
say "0x$_" for hexadecimal_words_from($file, $max_subs);

sub hexadecimal_words_from ($file, $max_subs) {
   open my $fh, '<:encoding(UTF-8)', $file or die "open('$file'): $!\n";
   map { hexadecimal_word($_, $max_subs) } <$fh>;
}

sub hexadecimal_word ($candidate, $max_subs = 8) {
   state $HEX_LETTERS = { map { $_ => 1 } 'a' .. 'f' };
   state $DIGIT_FOR = { qw< o 0 i 1 l 1 s 5 t 7 > };
   $candidate =~ s{\s+}{}gmxs;
   my @retval;
   for my $char (split m{}mxs, $candidate) {
      if (exists $HEX_LETTERS->{$char}) { push @retval, $char; next }
      return unless exists $DIGIT_FOR->{$char};
      return if --$max_subs < 0;
      push @retval, $DIGIT_FOR->{$char};
   }
   return join '', @retval;
}
```

Really folks, [Path::Tiny][] should be CORE. Whatever.

The rest is pretty much a 1:1 translation from [Raku][], except where
it isn't.

Awww, I'm really into explaining myself tonight!

Stay safe all!

[Path::Tiny]: https://metacpan.org/pod/Path::Tiny
[The Weekly Challenge]: https://theweeklychallenge.org/
[#166]: https://theweeklychallenge.org/blog/perl-weekly-challenge-166/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-166/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[GitHub repository]: https://github.com/manwar/perlweeklychallenge-club
[Week #161]: https://theweeklychallenge.org/blog/perl-weekly-challenge-161/
