---
title: Pronunciation defects
type: post
tags: [ rakulang, perl, advent of code ]
comment: true
date: 2021-09-04 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I'm probably not using regular expressions in [Raku][] the way they're
> designed to work better.

Although I like my strong [Perl][] accent while writing [Raku][] code,
it's probably time to correct a couple of... *pronunciation defects*.

It all started with [Advent of Code][] [2018][aoc-2018] [puzzle
5][aoc-2018-05]. Taking it as an excuse to do some more [Raku][]
exercising, I coded a solution for the first half of the day's puzzle:

```raku
sub part1 ($inputs is copy) {
   my $changed = -1;
   while ($changed && $inputs.chars) {
      $changed = 0;
      my $current = $inputs.substr(0, 1);
      my $i = 0;
      while $i < $inputs.chars - 1 {
         my $succ = $inputs.substr($i + 1, 1);
         if ($current ne $succ && lc($current) eq lc($succ)) {
            ++$changed;
            $inputs.substr-rw($i, 2) = '';
            $current = substr($i, 1) if $i < $inputs.chars;
         }
         else {
            $current = $succ;
            ++$i;
         }
      }
   }
   return $inputs.chars;
}
```

This is probably a rather boring implementation that might be
*idiomized* a lot. But with my current skills... I think the best I can
do is to *idiotize* it, so it's working and I call it a day.

Or do I? Certainly not!

I wondered about using a regular expression and [substitution][] to get
the job done, so I proceeded to *over-engineer* a solution:

```raku
sub part1_matcher () {
   my $allpairs =('a' .. 'z').map({ .lc ~ .uc, .uc ~ .lc }).flat.join('|');
   return rx{<$allpairs>};
}

sub part1_rx ($inputs is copy) {
   state $matcher = part1_matcher();
   Nil while $inputs ~~ s:g/$matcher//;
   return $inputs.chars;
}
```

I know, I know... it's a one-off script, what's my problem with
computing the regular expression once and put it in a `state` variable?
I'm a romantic.

So there I am all happy waiting for a solid performance boost, and I get
this:

```
$ time RX=1 raku 05.raku 05.input
...
real	0m54.025s
user	0m54.008s
sys	0m0.220s

$ time RX=0 raku 05.raku 05.input
...
real	0m9.601s
user	0m9.652s
sys	0m0.192s
```

You're guessing it right: the version **with** the regular expression
takes about `6x` times than the boring one!

At this point I was intrigued and wondered if it had to do with the
*approach*, so of course I re-implemented the whole thing in [Perl][].
Here's the *boring* translation:

```perl
sub part1 ($inputs) {
   my $changed = -1;
   while ($changed && length$inputs) {
      $changed = 0;
      my $current = substr $inputs, 0, 1;
      my $i = 0;
      while ($i < length($inputs) - 1) {
         my $succ = substr $inputs, $i + 1, 1;
         if ($current ne $succ && lc($current) eq lc($succ)) {
            ++$changed;
            substr $inputs, $i, 2, '';
            $current = substr($i, 1) if $i < length $inputs;
         }
         else {
            $current = $succ;
            ++$i;
         }
      }
   }
   return length $inputs;
}
```

and here's the regular-expressions based version translation:

```perl
sub part1_matcher () {
   my $allpairs = join '|',
      map { (lc($_) . uc($_), uc($_) . lc($_)) } 'a' .. 'z';
   return qr{$allpairs};
}

sub part1_rx ($inputs) {
   state $matcher = part1_matcher();
   1 while $inputs =~ s/$matcher//g;
   return length $inputs;
}
```

This time this is what I got back:

```
$ time RX=1 perl 05.pl 05.input
...
real	0m0.137s
user	0m0.108s
sys	0m0.008s

$ time RX=0 perl 05.pl 05.input
...
real	0m1.385s
user	0m1.340s
sys	0m0.024s
```

Now **this** is what I was expecting!

My (transitory?) take away is that one or more of the following apply:

- [Raku][] still has some way to go as long as performance is concerned
  (this is fair enough);
- I can *definitely* improve my [Raku][] to leverage on its strengths,
  instead of writing code *with my strong [Perl][] accent*.

Sometimes, having a strong accent just means that it will take you much
more time to be understood...

Thanks in anticipation to anybody that can help understanding what I'm
doing wrong and where I can improve!

Until next time... stay safe and have `-Ofun`!


[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Advent of Code]: https://adventofcode.com/
[aoc-2018]: https://adventofcode.com/2018/
[aoc-2018-05]: https://adventofcode.com/2018/day/5
[substitution]: https://docs.raku.org/language/regexes#Substitution
