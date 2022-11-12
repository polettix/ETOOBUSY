---
title: A path function in dibs
type: post
tags: [ dibs, perl, docker ]
comment: true
date: 2021-03-13 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I added a new function in [dibs][] expansion for variables.

Again. My [*maximum overkill system*][dibs] for building [Docker][]
images got some time from me.

This time... it just made sense.

At the very beginning, I had the problem to pass proper paths to the
programs run *inside* the container, which led to a system for expanding
those paths as part of *massaging* the argument list before running the
programs themselves.

Then came variables. A pretty rough system for handling variables, but
sufficient for my needs. And with variables... came some functions to
dynamically compute them. As an example:

```yaml
variables:
  - &foo 'this is foo'
  - &bar 'this is bar'
  - &baz [join, '|', *foo, 'whatever', *bar]
```

does what you think, i.e. generate a value `this is foo|whatever|this is
bar` that is associated to YAML anchor `baz`.

So you see it, right? It just made sense to have a new `path` function
and allow me define all paths in the `variables` section, so that I
don't have to pepper the arg lists with the expansions:

```yaml
variables:
  - &prereqs_dir  [path, src,   prereqs]     # .../src/prereqs
  - &cache_target [path, cache, my, target]  # .../cache/my/target
```

In hindsight, I have to say this about [dibs][]:

- I still like using it
- It's terribly undertested
- It's also inadequately documented, especially for hacking on it, BUT
- It's still easy to tweak it, even after so much time I don't work
  actively on it.

All in all... I'll continue using it 😄

[Docker]: https://www.docker.com/
[dibs]: https://blog.polettix.it/hi-from-dibs/
