---
title: PWC165 - Scalable Vector Graphics (SVG)
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-05-17 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#165][]. Enjoy!

# The challenge

> *Scalable Vector Graphics* (SVG) are not made of pixels, but lines,
> ellipses, and curves, that can be scaled to any size without any loss
> of quality. If you have ever tried to resize a small JPG or PNG, you
> know what I mean by “loss of quality”! What many people do not know
> about SVG files is, they are simply XML files, so they can easily be
> generated programmatically.
>
> For this task, you may use external library, such as Perl’s [SVG][]
> library, maintained in recent years by our very own `Mohammad S
> Anwar`. You can instead generate the XML yourself; it’s actually quite
> simple. The source for the example image for `Task #2` might be
> instructive.
>
> Your task is to accept a series of points and lines in the following
> format, one per line, in arbitrary order:
>
> **Point**: x,y
>
> **Line**: x1,y1,x2,y2
>
> **Example**:
>
>     53,10
>     53,10,23,30
>     23,30
>
> Then, generate an SVG file plotting all points, and all lines. If done
> correctly, you can view the output `.svg` file in your browser.

# The questions

No specific question, although maybe...

- should we put points consistently above or below lines?
- is there a preferred choice of colors/sizes?
- what size should the final image be advertised as?

# The solution

This solution is entirely how *not* to solve the problem, because we
should be relying upon modules to do this (like the [SVG][] module in
the very challenge text). Let's take this as a small exercise in
reinventing wheels badly.

We go [Raku][] first, as it's become customary. We have three
lower-level functions to build upon, to handle generation of taggish
struff, plus two drawing primitives for point and line.

```raku
#!/usr/bin/env raku
use v6;
sub MAIN {
   put svg-for("53,10\n53,10,23,30\n23,30")
}

sub svg-for ($input) {
   (
      gather {
         take open-tag('svg', width => 400, height => 400);
         for $input.lines -> $line {
            my @nums = $line.split(/ \, /);
            take @nums == 2 ?? point(@nums) !! line(@nums);
         };
         take close-tag('svg');
      }
   ).join("\n");
}

sub open-tag ($tag, *%args) {
   ("<$tag", %args.kv.map(-> $k, $v {qq<$k="$v">}), '>').join(' ');
}

sub oneshot-tag ($tag, *%args) {
   ("<$tag", %args.kv.map(-> $k, $v {qq<$k="$v">}), '/>').join(' ');
}

sub close-tag ($tag) { return "</$tag>" }

sub point (@p, *%args) {
   my %pargs =
      'cx', @p[0],
      'cy', @p[1],
      'r', 4,
      'stroke-width', 0,
      'fill', '#000000'
      ;
   oneshot-tag('circle', |%pargs, |%args);
}

sub line (@ps, *%args) {
   my %pargs =
      'points', @ps.join(' '),
      'stroke-width', 6,
      'stroke', '#ff0000';
   oneshot-tag('polyline', |%pargs, |%args);
}
```

I still have to get the hang of passing parameters properly in [Raku][]
and, to be honest, I **much** prefer the way it's done in [Perl][], at
least from a day-to-day perspective. It's either the variable or a
reference to it there, one rule to learn and we're up to speed; here...
we have to think *so much more*.

Whatever.

For the [Perl][] alternative, I did it even more badly if possible. I'm
using my own [Template::Perlish][] module to define a template which
implements exactly what's requested. So in a sense I'm using [CPAN][],
but not how I'm supposed to do it in real life.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use Template::Perlish;

say svg_for("53,10\n53,10,23,30\n23,30");

sub svg_for ($text) {
   state $tp2 = Template::Perlish->new->compile_as_sub(
q{<svg height="400" width="400">
[% for my $item (A 'lines') {
      if ($item->@* == 2) {
%] <circle r="4" cx="[%= $item->[0] %]" cy="[%= $item->[1] %]" stroke-width="0" fill="#000000" />
[%    } else {
%] <polyline points="[%= join ' ', $item->@* %]" stroke="#ff0000" stroke-width="6" />
[%    }
   }
%]</svg>});
   $tp2->({lines => [map {[ split m{,+}mxs ]} split m{\n+}mxs, $text]});
}
```

All in all, though, **I** find it more readable.

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#165]: https://theweeklychallenge.org/blog/perl-weekly-challenge-165/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-165/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[SVG]: https://metacpan.org/pod/SVG
[CPAN]: https://metacpan.org/
[Template::Perlish]: https://metacpan.org/pod/Template::Perlish
