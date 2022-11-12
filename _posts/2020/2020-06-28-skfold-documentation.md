---
title: 'skfold - documentation'
type: post
tags: [ perl, coding, skfold ]
series: skfold
comment: true
date: 2020-06-28 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> At the very last, I added some basic documentation to [skfold][].

And that's pretty it. Well, you can...

- ... call without parameters, and get a list of modules:

```shell
# skf version 0.1.0 - more info with
# skf --usage|--help|--man
# Available modules:
perl-distro
dibs
```

- ... try to get help for a module, and get a nice error about my
  lazyness:

```shell
$ bin/skf -h dibs
Unimplemented at bin/skf line 287.
```

- ... get some help, via `--usage`, `--help`, and `--man`.

Now I guess it's really it!


[skfold]: https://github.com/polettix/skfold
[Perl]: https://www.perl.org/
[dibs]: http://blog.polettix.it/hi-from-dibs/
