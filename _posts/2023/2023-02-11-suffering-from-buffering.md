---
title: Suffering from Buffering
type: post
tags: [ perl ]
comment: true
date: 2023-02-11 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Close your handles, especially from [File::Temp][]!

I recently wrote [this code][commit]:

```perl
sub data_to_file {
   my $keep = $_[1] // 0;
   require File::Temp;
   my ($fh, $filename) = File::Temp::tempfile(UNLINK => (!$keep));
   binmode $fh, ':raw';
   print {$fh} ref($_[0]) ? ${$_[0]} : $_[0];
   return $filename;
} ## end sub data_to_file
```

It's part of [Data::Resolver][], which I *released* but only to make
[CPAN Testers][] take note of it. And, well, use it [elsewhere][].

What's wrong with it? At least a couple of things:

- the `print` might fail, but I happily skip over it
- I don't close the `$fh` filehandle, nor check the closing operation
  (of course).

This is *usually* not a problem, because these operations "rarely" fail
in a hobbyst's scenario, plus [Perl][] closes filehandle when they go
out of scope.

Anyway, it hit me quite hard recently because I was getting truncated
data back. I suspect that getting a filehandle from [File::Temp][] means
that it's not closed automatically when it goes out of scope in *my*
function, hence the issue.

So well, yeah: a buffering-related problem.

Which reminded me of the excellent article [Suffering from Buffering][]
by [Mark Jason Dominus][] - the *true* inspiration for this post's title
and most importantly a recommended read!

Stay safe!


[Perl]: https://www.perl.org/
[commit]: https://codeberg.org/polettix/Data-Resolver/src/commit/5583319ec9e9bd40756978fb45cabe218917a602/lib/Data/Resolver.pm#L182
[Data::Resolver]: https://metacpan.org/pod/Data::Resolver
[CPAN Testers]: https://cpantesters.org/
[elsewhere]: https://codeberg.org/polettix/PDF-Collage
[File::Temp]: https://metacpan.org/pod/File::Temp
[Suffering from Buffering?]: https://perl.plover.com/FAQs/Buffering.html
[Mark Jason Dominus]: https://blog.plover.com/meta/about-me.html
