---
title: Romeo teepee gets looping option
type: post
tags: [ perl ]
series: Romeo
comment: true
date: 2023-07-30 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [Romeo][]'s sub-command `teepee` can now loop over data automatically.

Remember [Romeo][]? Yes, the *hydra-like* [Perl][] program that sometimes
makes my life easy.

It contains a sub-command `teepee`, which is meant to capture most of what
the standalone program [teepee][] does, so that I can carry one less program
with me.

I often end up having input *data* shaped as an *array* of hashes, that I
have to iterate over. Well, templates being fully [Perl][]-capable, this is
pretty easy to do:

```
[% for my $record (A()) { %]
Hey [%= $record->{some}{nested}{data} %]!
[% } %]
```

There are a couple of drawbacks with this:

1. using `$record` is easy in the template part inside the loop, but *not
   straightforward*. In particular, what would be a simple expression for
   getting `[% some.nested.data %]` becomes a more cumbersome `[%=
   $record->{some}{nested}{data} %]`
2. the whole thing seems less readable.

From [version 0.030][] on, there's a new command-line option `--loop`/`-l`
to help with this. When enabled and the input data is an array, it will then
loop over each item in the array and render the provided template with the
item as data, stitching the results together. Hence, the example template
above can be designed to work on a single record:

```
Hey [% some.nested.data %]!
```

and [Romeo][] will take care of the looping.

Want to get it right now? Here's how:

```
# with curl
curl -LO https://codeberg.org/polettix/Romeo/raw/branch/main/romeo
chmod +x romeo
mv romeo /some/where/in/PATH

# with wget
wget https://codeberg.org/polettix/Romeo/raw/branch/main/romeo
chmod +x romeo
mv romeo /some/where/in/PATH
```

I hope this can be useful, cheers!

[Perl]: https://www.perl.org/
[Romeo]: {{ '/2023/03/07/fun-with-romeo/' | prepend: site.baseurl }}
[teepee]: {{ '/2021/03/16/teepee/' | prepend: site.baseurl }}
[version 0.030]: https://codeberg.org/polettix/Romeo/src/tag/v0.030
