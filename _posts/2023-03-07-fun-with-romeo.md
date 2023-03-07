---
title: Fun with Romeo
type: post
tags: [ perl ]
series: Romeo
comment: true
date: 2023-03-07 06:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I'm having fun with [Romeo][].

Romeo was a cat friend that left us last November, and we're missing him
a lot.

![Romeo]({{ '/assets/images/romeo.jpg' | prepend: site.baseurl }})

He was a funny cat, though, so I thought of having some fun with
[Perl][] and dedicate the resulting program to him. I hope you can have
fun with [Romeo][] too.

It's an aggregate of several different programs to do mostly unneeded
things, but your mileage may vary. If you want to try it out, the most
straightforward way is to make sure you have `perl` version 5.24 or
later, download the [bundled version][] and set the execution bit:

```
curl -LO https://codeberg.org/polettix/Romeo/raw/branch/main/romeo
chmod +x romeo
```

One thing that I *hope* I got right is the copyright stuff for the
bundled version. It contains several modules from CPAN, which I've
included inside the repository without the POD documentation; for this
reason, I thought of adding the notices directly inside the program, so
that they can be easily accessed even from just the installed bundled
program:

```
$ romeo --copying

Except for what described below, the contents of this
repository/package/program are licensed according to the Apache License 2.0:
...

This version of the program contains a bundle of the modules it depends on,
stripped of their respective documentation to squeeze them as much as
possible (or reasonable, anyway).

The original code belongs to the respective authors; you can find the
original code in CPAN, e.g.:

- "App::Easer" - https://metacpan.org/dist/App-Easer
- "Ouch" - https://metacpan.org/dist/Ouch
- "Path::Tiny" - https://metacpan.org/dist/Path-Tiny
- "Role::Tiny" - https://metacpan.org/dist/Role-Tiny
- "Template::Perlish" - https://metacpan.org/dist/Template-Perlish
- "Term::ANSIColor" - https://metacpan.org/dist/Term-ANSIColor
- "Text::CSV" - https://metacpan.org/dist/Text-CSV
- "Try::Catch" - https://metacpan.org/dist/Try-Catch

Additionally, the program also bundles a copy of the X11 "rgb.txt" file with
X11 color definitions.
...
```

Then module-specific notes about copyright and licensing follow, taken
from the respective documentation and stripping away email addresses
(just to lower the spam a bit).

Have fun with [Romeo][]!

[Perl]: https://www.perl.org/
[Romeo]: https://codeberg.org/polettix/Romeo
[bundled version]: https://codeberg.org/polettix/Romeo/raw/branch/main/romeo
