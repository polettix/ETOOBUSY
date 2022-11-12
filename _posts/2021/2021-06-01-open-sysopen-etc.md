---
title: 'Open, sysopen, read, sysread... oh my!'
type: post
tags: [ perl ]
comment: true
date: 2021-06-01 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> [open][] and [read][] are usually fine.

In recent post [Random bytes and co.][] I wrote a function to read
exactly 16 bytes from `/dev/urandom`:

```perl
sub salt_please {
   open my $fh, '< :raw :bytes', '/dev/urandom'
      or die "open('/dev/urandom'): $!\n";
   my $retval = '';
   while ((my $len = length $retval) < 16) {
      read($fh, $retval, 16 - $len, $len) // die "read(): $!\n"
   }
   close $fh;
   return $retval;
}
```

My first thought was to use `sysopen` and `sysread`, but then I took a
look at [perlopentut][] and figured that it was *not* needed.

Then of course I wondered... *when should I use one or the other?!?*

Here's something I collected.

# They don't pair

The first thing is that there is no pairing, i.e. you can use `read`
with filehandles opened with `sysopen`, and use `sysread` with
filehandles opened with `open`.

# `open` is almost certainly good

[What's the difference between open and sysopen in Perl?][so-open]

The bottom line is that everyday usage for a multitude of files is fine
with [open][]. As put in [this answer][so-open-answer]:

> Unless you are working with a specific device that requires some
> special flags to be passed at `open(2)` time, for ordinary files on disk
> you should be fine with [open][].

One comment in the answer provides an excellent example of using
[sysopen][] over [open][]:

> [...] consider `O_WRONLY|O_EXCL|O_CREAT` combo, i.e. "create and write
> if not exists". Using `-f ... or open ...` instead is just asking for
> race condition.

So there I have it, to read (binary) data from `/dev/urandom` I will
just [open][] passing `:raw :binary` as suggested in [perlopentut][].

# `read` is almost certainly good

[What is the difference between `read` and `sysread`?][so-read]

I'll just copy-paste the author's conclusions:

> - [read][] works with any Perl file handle, while [sysread][] is
>   limited to Perl file handles mapped to a system file
>   handle/descriptor.
> - read isn't compatible with [select][] (I'm referring to the
>   4-argument one called by [IO::Select][]), while [sysread][] is
>   compatible with select.
> - [read][] can perform decoding for you, while [sysread][] requires
>   that you do your own decoding.
> - [read][] should be faster for very small reads, while [sysread][]
>   should be faster for very large reads.

Maybe I'm oversimplifying, but I think I'll leave [sysread][] for
sockets etc. and stick to [read][] if I'm reading local stuff.

[Random bytes and co.]: {{ '/2021/05/31/random-bytes-and-co/' | prepend: site.baseurl }}
[perlopentut]: https://perldoc.perl.org/perlopentut
[open]: https://perldoc.perl.org/functions/open
[select]: https://perldoc.perl.org/functions/select
[sysopen]: https://perldoc.perl.org/functions/sysopen
[so-open]: https://stackoverflow.com/questions/7486414/whats-the-difference-between-open-and-sysopen-in-perl
[so-open-answer]: https://stackoverflow.com/a/7486481/334931
[read]: https://perldoc.perl.org/functions/read
[sysread]: https://perldoc.perl.org/functions/sysread
[so-read]: https://stackoverflow.com/questions/36315124/what-is-the-difference-between-read-and-sysread
[IO::Select]: https://metacpan.org/pod/IO::Select
