---
title: Tutorials for modules
type: post
tags: [ text, writing, pod, markdown, perl ]
comment: true
date: 2021-11-29 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Some thoughts about writing tutorials for [Perl][] modules.

It's no secret I love [Perl][] and I have some modules in [CPAN][]. I'm
the main consumer of my modules (which is a generous way to say *the
only*...) but a rather happy one, because I actually make use of the
from time to time, and find the documentation up to my expectations.

Well... *mostly*.

I tend to focus documentation on being a good *reference* (with dubious
results, as future me sometimes finds out), but it's terribly lacking
from the point of view of using the module *quickly*.

Module [App::Easer][] is no exception: there are definitely some edges
that can benefit from some smoothing. This is where I think that one or
more *tutorials* would be perfect.

And this is also where I enter the rabbit hole.

As a general rule, I want to be as general as possible. Any doc I write
should be readable from the command line through the venerable
[perldoc][], as well as on [metacpan.org][CPAN], as well as on
[GitHub][].

The natural choice is then to write the tutorial(s) in [Plain Old
Documentation][POD] format: its support in [Perl][] is... *excellent*,
of course, and [GitHub][] renders it great too (e.g. see [the
documentation for App::Easer 0.007][pod-in-gh]).

So... problem solved, right? [POD][] to the rescue, right?

Well, *not so fast*.

I like writing in [Markdown][] better, to the point that I often use it
inside modules documentation, which does not get me what I want.
Additionally, I'd also like these tutorials to work fine as a small
website for the modules, which would be a no-brainer with [Markdown][]
because I could just push the files and everything would be all right.

Hence, I'm actually thinking about writing the documentation in
[Markdown][], and then convert it *back* to [POD][] to also ship it with
the modules themselves.

Then - *possibly* - switch to [POD][] as the main source and use it to
generate the tutorial's website. Why? My understanding is that the
pipelines from [POD][] to something else (remember
[Pod::Markdown and Pod::Markdown::Github for the win!][post]) are
somehow less brittle (or heavy) than the other way around, so it's also
hopefully easier to automate the conversion completely.

Time will tell. In the meantime... stay safe!


[Perl]: https://www.perl.org/
[CPAN]: https://metacpan.org/
[App::Easer]: https://metacpan.org/pod/App::Easer
[perldoc]: https://perldoc.perl.org/perldoc
[GitHub]: https://www.github.com/
[pod-in-gh]: https://github.com/polettix/App-Easer/blob/5398a6894555a137e9e20bb2720a585ab115507d/lib/App/Easer.pod
[POD]: https://perldoc.perl.org/perlpod
[Markdown]: https://daringfireball.net/projects/markdown/
[post]: {{ '/2021/08/24/pod-markdown-github' | prepend: site.baseurl }}
