---
title: Codeberg Pages - Custom domains
type: post
tags: [ codeberg ]
series: Codeberg
comment: true
date: 2022-07-18 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Some remarks on using custom domains in [Codeberg Pages][].

The instructions at [Codeberg Pages][] *were* concise and to the point,
although possibly *a little too much*. Even the [documentation page][],
although more verbose, left me with some holes. I'm very happy that I
could help a bit with a few examples and [they were accepted][]!

One thing that I learned *the hard way* was how the `.domains` file is
supposed to be written. Initially, I thought that setting the custom
domain was sufficient, like this:

```
custom.example.com
```

This is, after all, how it is done with a similar file in a different
platform.

Alas, this is not the case. Then I noticed this in the old docs:

> a `.domains` file in the repository (in the branch in question),
> containing a list of domains that shall be usable to access that
> repository:
>
> - One domain per line, you can leave lines empty and comment out lines
> with `#`.
>
> - All domains (including `*.codeberg.page`) will be redirected to the
> first domain in that file.

The second bullet was interesting and pointed me to the right direction.
I initially thought that it was some optional part but no, it's
necessary!

So the right file has *at least* two rows, the first one with the custom
domain, and the other ones all the [Codeberg Pages][] sub-domains tied
to that custom domain, like this:

```
custom.example.com
custom.username.codeberg.page
```

**Now** it worked for me!

[Gusted][] helped me to fix the changes to make things clearer, which
led us to this:

> a .domains file in the repository (in the branch in question),
> containing a list of all domains that shall be usable to access that
> repository, according to the following rules:
>
> - One domain per line, you can leave lines empty and comment out lines
> with #.
>
> - The first domain is the main one where all other domains in the file
> will be redirected to.
>
> - The rest of the list includes also all relevant `*.codeberg.page`
> domains for the specific repository.

If it's still unclear to you... by al means chime in, people at
[Codeberg][] are very supportive!

Stay safe folks!

[Codeberg]: https://codeberg.org/
[Codeberg Pages]: https://codeberg.page/
[documentation page]: https://docs.codeberg.org/codeberg-pages/
[they were accepted]: https://codeberg.org/Codeberg/Documentation/pulls/241
[Gusted]: https://codeberg.org/Gusted
