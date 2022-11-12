---
title: 'Resuming Data::Tubes'
type: post
tags: [ perl, text processing ]
comment: true
date: 2021-10-11 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I (re)used [Data::Tubes][] to address an issue.

I'm helping a friend deal with an issue regarding some
not-so-complicated data handling and one of the files that we had to
parse has a 80-ish format with *fixed fields* in specific lines.

The entire format is according to an Italian specification about the
so-called *CBI format*. The bottom line is that there are...

- ... *records* that are formed by multiple lines, each with its own
  type and data
- ... *lines* have a fixed 120-characters-long format, where characters
  means bytes.

It's been an occasion for me to resume [Data::Tubes][] and see if past
me has been gentle with *present me*. As always, docs can be enhanced
but overall I had a good experience with getting up to speed again after
forgetting almost everything (apart from the underlying generic
philosophy).

The main pipeline I came up with is the following:

```perl
my $p = pipeline(
   'Source::open_file',
   ['Reader::by_line', emit_eof => 1],
   line_tracker(),
   \&parse_cbi_line,
   cbi_aggregator(),
   [
      'Plumbing::dispatch',
      key => 'type',
      factory => sub { return \&nop }, # ignore stuff by default
      handlers => {
         disposizione => \&aggregate_disposition,
      },
   ],
   sub ($r) { $r->{info} }, # keep info field only for output
   {tap => 'array'},
);
```

This pipeline expects to receive a file name as an input and start
processing it:

- input files are opened;
- each file is read by the line - this "explodes" each input record (an
  opened file) into multiple output records (one per line);
- the `line_tracker` only serves the purpose of tracking the line
  number, should it be necessary (e.g. if nobody asked for it)
- the `cbi_aggregator` takes multiple input records - corrisponding to
  the different pieces of information for a record - and coalesces them
  into a single record per operation (comprising multiple input parts)
- the *plumbing* part is to make sure that we only keep what we're
  really interested into (full records pertaining a specific operation,
  not every possible one) while ignoring the rest (the *factory* by
  default ignores the record)
- the last tube gets rid of most of the "housekeeping stuff" and retains
  the interesting part of the record, that is whatever has been
  collected into `info`.
- Last, weask the pipeline to return an array instead of throwing
  everything down the sink.

There are a few rough edges here and there in the docs - e.g. it would
be good if I documented a bit better what comes in and out of some
functions, and add more examples about their intended usage. All in all,
anyway, I have to thank past me for making it easy for me to use
[Data::Tubes][] 😄

Stay safe and have fun, folks!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Data::Tubes]: https://metacpan.org/pod/Data::Tubes
