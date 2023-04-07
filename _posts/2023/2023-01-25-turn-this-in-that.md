---
title: Turn this in that
type: post
tags: [ perl ]
comment: true
date: 2023-01-25 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A few [Perl][] helpers.

I'm working on a little project to turn [pdfunnel][] into a module, and
for *reasons* I might have data in a "format" (e.g. loaded as a scalar
in memory) and need it in another format (e.g. a file or a filehandle).

Hence I decided to code a few functions to tranform into these three
formats:

- `data` in memory;
- `path` to a file;
- `fh`, i.e. a filehandle.

The following function are, as of now... totally untested:

```perl
sub data_to_fh ($data) { path_to_fh(ref($data) ? $data : \$data) }

sub data_to_path ($data) {
   require File::Temp;
   my ($fh, $filename) = File::Temp::tempfile(UNLINK => 0);
   binmode $fh, ':raw';
   print {$fh} ref($data) ? $data : $$data;
   return $filename;
} ## end sub data_to_path

sub fh_to_data ($fh) { local $/; readline($fh) }

sub fh_to_path ($fh) { data_to_path(fh_to_data($fh)) }

sub path_to_data ($input) { fh_to_data(path_to_fh($input)) }

sub path_to_fh ($input) {
   open my $fh, '<:raw', $input or croak "open('$input'): $OS_ERROR";
   return $fh;
}
```

So well, yeah... this is as much of an incomplete post as it can be, but
I set a goal to write/publish something every day, not to always write
self-contained meaningful stuff!

Cheers!

[Perl]: https://www.perl.org/
[pdfunnel]: {{ '/2022/11/09/pdfunnel/' | prepend: site.baseurl }}
