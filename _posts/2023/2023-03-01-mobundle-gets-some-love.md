---
title: mobundle gets some love
type: post
tags: [ perl ]
comment: true
date: 2023-03-01 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> [mobundle][] got some attention after years.

After [writing about mobundle][post], I thought to try it again outside
of my VM echo chamber, and I hit a first roadblock: no
[cpanfile][install]!

It was quite straightforward, to be honest:

```perl
requires 'File::Slurp';
requires 'Path::Class';
requires 'Template::Perlish';
```

Well... *not so fast*, because the program can *optionally* leverage
[Module::ScanDeps][] too:

```perl
requires 'File::Slurp';
requires 'Module::ScanDeps';
requires 'Path::Class';
requires 'Template::Perlish';
```

At this point I decided to add a new feature, to optionally inject the
list of bundled modules in a package variable `@__MOBUNDLE_MODULES__`
(for reasons that will hopefully become clear in a future post).

Still, it was not complete. What good is a bundling application if I
don't even *try* to produce a bundled version? So I added [quine.sh][]:

```shell
#!/bin/sh
md="$(dirname "$(readlink -f "$0")")"
PERL5LIB="$md/local/lib/perl5" "$md/mobundle" -LPo "$md/bundle/mobundle" \
   -m File::Slurp \
   -m Module::ScanDeps \
   -m Module::ScanDeps::Cache \
   -m Path::Class::Entity \
   -m Path::Class::File \
   -m Path::Class::Dir \
   -m Path::Class \
   -m Template::Perlish \
   "$md/mobundle"
chmod +x "$md/bundle/mobundle"
```

Although it can *optionally* use [Module::ScanDeps][], I have to admit
that I like to curate the list of modules by hand. 

So, now, there's a [bundled version of mobundle][bundled]!

```
url='https://repo.or.cz/mobundle.git/blob_plain/HEAD:/bundle/mobundle'
curl -Lo "$url" && chmod +x mobundle    && mv mobundle ~/bin
```

> If you're wondering about the weird spacing in the command above, it
> is to make it easier to **not** select the `mv ...` part, so that you
> can decide whether you want to put the downloaded program in `~/bin`
> or not by just selecting it or not.

Last, I moved to an [Apache license][]. I hope I understood how this
licensing thing works, namely...

- ... that I can change license from a certain version on
- ... that I can embed others' modules and make reference to their
  license in the program's documentation.

Stay compact and bundled!

[Perl]: https://www.perl.org/
[mobundle]: https://repo.or.cz/mobundle.git
[post]: {{ '/2023/02/21/mobundle/' | prepend: site.baseurl }}
[install]: {{ '/2020/01/04/installing-perl-modules/' | prepend: site.baseurl }}
[Module::ScanDeps]: https://metacpan.org/pod/Module::ScanDeps
[quine.sh]: https://repo.or.cz/mobundle.git/blob/HEAD:/quine.sh
[bundled]: https://repo.or.cz/mobundle.git/blob_plain/HEAD:/bundle/mobundle
