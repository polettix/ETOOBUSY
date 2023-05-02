---
title: Reinstalling R
type: post
tags: [ R, statistics ]
comment: true
date: 2023-05-02 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A few notes about reinstalling [R][].

I'm following the excellent lectures [Statistical Rethinking 2023][] by
[Richard McElreath][]. They're just... *wow*, although I definitely have
some dust to remove (I hope the book will help along with the lectures).

To follow the examples and do the exercises, I decided to download and
install [R][]. I'm using Windows in this period, so it's actually
*re-installing* [R][], because I've used it in MacOS previously.

I got this so far:

- [The base package][].
- [RStudio][].
- [RTools][] ([version 4.3][rt4.3]).

At this point, I headed to [rethinking][], which implied:

- [RStan][].
- [cmdstanr][].

Here I got stuck because apparently `CmdStan` (I don't even know what
it's about) requires [RTools version 4.2][rt4.2], or installing it via
`conda`. I tried:

- [RTools version 4.2][rt4.2].

and it seems to have worked with [the instructions][cmdstanr]:

```
library(cmdstanr)
check_cmdstan_toolchain(fix = TRUE, quiet = TRUE)
install_cmdstan(cores = 2)
```

Hopefully, support for [RTools version 4.3][rt4.3] will be added soon,
but in the meantime... Now on with:

- [rethinking][].

At this point, as strange as it might seem... we're done!

Stay safe and cheers!

[R]: https://www.r-project.org/
[Statistical Rethinking 2023]: https://www.youtube.com/playlist?list=PLDcUM9US4XdPz-KxHM4XHt7uUVGWWVSus
[Richard McElreath]: https://www.youtube.com/@rmcelreath
[the base package]: https://cran.mirror.garr.it/CRAN/bin/windows/base/
[RStudio]: https://posit.co/download/rstudio-desktop/
[RTools]: https://cran.r-project.org/bin/windows/Rtools/
[rt4.3]: https://cran.r-project.org/bin/windows/Rtools/rtools43/rtools.html
[rt4.2]: https://cran.r-project.org/bin/windows/Rtools/rtools42/rtools.html
[RStan]: https://mc-stan.org/users/interfaces/rstan.html
[cmdstanr]: https://mc-stan.org/cmdstanr/
[rethinking]: https://github.com/rmcelreath/rethinking/
