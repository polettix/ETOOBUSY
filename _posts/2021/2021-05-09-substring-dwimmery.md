---
title: Substring DWIMmery
type: post
tags: [ perl ]
comment: true
date: 2021-05-09 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I was reminded that [`substr`][] Does What I Mean.

As already pointed out in [Avoid the "butterfly operator" with
command-line options][] , [this tweet][] from [Αριστοτέλης
Παγκαλτζής][giant] was precious for learning new stuff:

![tweet screenshot]({{ '/assets/images/ap-tweet-0777.png' | prepend: site.baseurl }})

In addition to [option `-0xxx`][], another part struck me, i.e. the
removal of the opening and closing square brackets from the encoded
string like this:

```perl
$str = substr $str, 1, -1;
```

It ***just makes sense*** that `-1` can be used in [`substr`][] to say
*up to the 1-before-last character of the string*, but for some reason
this never stuck in my brain and I'm positive that I would have written
this in the longer and error prone way:

```perl
my $len = length $str;
$str = substr $str, 1, $len - 2;
```

or in the additionally less readable way:

```perl
$str = substr $str, 1, length($str) - 2;
```

So there you have it: [Αριστοτέλης][giant] taught me not one but *two*
things with [one single tweet][this tweet].

Selfishly speaking... it's an excellent reason to write stuff 😄

[option `-0xxx`]: https://perldoc.perl.org/perlrun#-0%5Boctal/hexadecimal%5D
[giant]: http://plasmasturm.org/about/#me
[this tweet]: https://twitter.com/apag/status/1389260909294542851
[`substr`]: https://perldoc.perl.org/functions/substr
[Avoid the "butterfly operator" with command-line options]: {{ '/2021/05/08/perlrun-no-butterfly/' | prepend: site.baseurl }}
