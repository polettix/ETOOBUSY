---
title: Aquarium - print puzzle
type: post
tags: [ aquarium puzzle game, coding, perl, constraint programming, Aquarium ]
series: Aquarium
comment: true
date: 2020-03-31 08:59:23 +0200
published: true
---

**TL;DR**

> Where much code is provided, with little to no explanation

After looking at how to [parse the input puzzle][] for [aquarium][], and
before going on in analyzing how to solve it, let's take an initial stop to
display it properly on the terminal.

The code is available in [stage 2][] inside the [aquarium-solver][]
repository. It leverages [Term::ANSIColor][] as well as a train of tricks
and hacks which do not exactly make me proud.

It works, see an example below:

![aquarium puzzle 681,742 solved]({{ '/assets/images/aquarium/aquarium-02.png' | prepend: site.baseurl | prepend: site.url }})

The *solution* in the [stage 2][] code is just hard-coded and valid for the
example puzzle, of course. It's just there to let us take a glimpse of what
to expect eventually...

Module [Term::ANSIColor][] needs to be installed, which can be done thanks
to the `cpanfile` in the [aquarium-solver][] repository. If you need help in
using it, please take a look at [Installing Perl Modules][]. The `cpanfile`
also contains indications to install module [Try::Catch][], which we will
use in later stages.

[parse the input puzzle]: {{ '/2020/03/30/aquarium-parse-puzzle/' | prepend: site.baseurl | prepend: site.url }}
[aquarium]: https://www.puzzle-aquarium.com/
[aquarium-solver]: https://gitlab.com/polettix/aquarium-solver/
[stage 2]: https://gitlab.com/polettix/aquarium-solver/-/blob/master/02-print/aquarium.pl
[Term::ANSIColor]: https://metacpan.org/pod/Term::ANSIColor
[Installing Perl Modules]: {{ '/2020/01/04/installing-perl-modules/' | prepend: site.baseurl | prepend: site.url }}
[Try::Catch]: https://metacpan.org/pod/Try::Catch
