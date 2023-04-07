---
title: Windows paths
type: post
tags: [ perl ]
comment: true
date: 2023-03-08 00:50:18 +0100
mathjax: false
published: true
---

**TL;DR**

> Windows paths are... different.

I'm in the process of producing a new release of [Data::Resolver][] and I
hit a small roadblock:

![Data::Resolver matrix for version 0.003001]({{ '/assets/images/data-resolver-0.3.1-matrix.png' | prepend: site.baseurl }})

Fate decided to have some fun and prevented me from reading the reports, but
folks at [CPAN Testers][] saved the day once again:

![CPAN Testers tweet exchange]({{ '/assets/images/cpan-testers-tweet-202303.png' | prepend: site.baseurl }})

It eventually landed me on the error:

```
#                   'C:\DOKUME~1\smoker\LOKALE~1\Temp\CV48qkF3Z_\foo'
#     doesn't match '(?^u:(?mxs:(?mxs: \A | /) foo \z))'
```

*Silly me!* Paths in Windows use a different path separator, so my regular
expression was wrong checking whether the bare file name was alone or
preceded by the Unix path separator.

No big deal, I decided to use [File::Basename][]'s `basename` to strip the
directory part and turn a `like` test into an exact one.

So here's your lesson, future me: always use [File::Spec][], its ecosystem
or other proven modules to mess with paths in the local filesystem, if you
value portability!

Stay safe and *portable*!

[Perl]: https://www.perl.org/
[Data::Resolver]: https://metacpan.org/pod/Data::Resolver
[CPAN Testers]: https://cpantesters.org/
[File::Basename]: https://metacpan.org/pod/File::Basename
[File::Spec]: https://metacpan.org/pod/File::Spec
