---
title: PWC181 - Sentence Order
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-09-08 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#181][]. Enjoy!

# The challenge

> You are given a paragraph.
>
> Write a script to order each sentence alphanumerically and print the
> whole paragraph.
>
> **Example**
>
>     Input:
>         All he could think about was how it would all end. There was
>         still a bit of uncertainty in the equation, but the basics
>         were there for anyone to see. No matter how much he tried to
>         see the positive, it wasn't anywhere to be seen. The end was
>         coming and it wasn't going to be pretty.
>
>     Ouput:
>         about All all could end he how it think was would. a anyone
>         basics bit but equation, for in of see still the the There
>         there to uncertainty was were. anywhere be he how it matter
>         much No positive, see seen the to to tried wasn't. and be
>         coming end going it pretty The to was wasn't.

# The questions

Decisions, decisions. Or, better, *definitions, definitions*.

For sake of simplicity, and in lack of further requirement:

- sentences are separated by full stops followed by a spacing character
- the last sentence has a full stop too
- words are separated by spacing characters
- sorting will happen case-insensitively (looking at the example)

Is this good? Is this *any* good? Anything more? Too simple?!?

# The solution

As it's tradition, let's start with [Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN { put sentence-order(paragraph()) }

sub sentence-order ($paragraph) {
   return $paragraph.split(/\.(\s*|$)/)
      .map({ .split(/\s+/).sort({ .fc }).join(' ') })
      .join('. ');
}

sub paragraph {
   return q:to/END/;
      All he could think about was how it would all end. There was
      still a bit of uncertainty in the equation, but the basics
      were there for anyone to see. No matter how much he tried to
      see the positive, it wasn't anywhere to be seen. The end was
      coming and it wasn't going to be pretty.
      END
}
```

There is an external pipeline dealing with sentences, and an internal
pipeline dealing with words. They are sorted without regard for case, so
we're using the `.fc` method on each element (nice feature of `sort`!).

I'm not entirely sure why the last sentence gets a full stop but it
does. I suspect that it also gets the space, of course, but it's
invisible right? 🙄

The [Perl][] counterpart is a little more predictable for me and I
*did not* get a full stop at the end, which is why I had to put one.
Without the space, this time, but with a newline, like any serious
paragraph.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say sentence_order(paragraph());

sub sentence_order ($paragraph) {
   $paragraph = join '. ',
      map { join ' ', sort { fc($a) cmp fc($b) } split m{\s+}mxs }
      split m{\.(?:\s+|\z)}mxs, $paragraph;
   return $paragraph . ".\n";
}

sub paragraph {
   return <<'END' =~ s{^\s+}{}rgmxs;
      All he could think about was how it would all end. There was
      still a bit of uncertainty in the equation, but the basics
      were there for anyone to see. No matter how much he tried to
      see the positive, it wasn't anywhere to be seen. The end was
      coming and it wasn't going to be pretty.
END
}
```

For the rest it's almost the same as [Raku][], which is anyway more
readable of course, because here in [Perl][] pipelines are written
backwards.

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#181]: https://theweeklychallenge.org/blog/perl-weekly-challenge-181/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-181/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
