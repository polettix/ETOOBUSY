---
title: PNG Attachments in Romeo
type: post
tags: [ perl, graphics, png ]
series: Romeo
comment: true
date: 2023-03-28 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A different take on [A new protocol and tool for PNG file attachments][].

In [Playing with PNG files][post] I introduced a blog post by Chris Wellons,
i.e. [A new protocol and tool for PNG file attachments][], where the author
proposes to use a *private* chunk type (named `atCh`) for attaching files to
a PNG file.

While the solution is sound, I'm not sure there was really a need for a new
type. My take is that the whole thing (filename and contents) might be
easily inserted in a small data structure with keys and values, *then*
encoded as JSON.

Why JSON? Well, it's at ease with serializing data structures, and its
encoded form is UTF-8, which happens to be the encoding mandated by the
contents in the `iTXt` PNG chunk (which also supports compression).

Which is what [`add_iTXt`][] does in [Romeo][]:

```perl
sub add_iTXt ($self, $raw_name, $contents) {
   $contents = encode_json(
      {
         filename => $self->proper_name($raw_name),
         bytes    => $contents,
      }
   );
   my $compressed = '';
   deflate(\$contents, \$compressed);

   my $data = join '',
      PORTABLE_ATTACHMENT_KEYWORD, # keyword as we like it
      "\0",                        # keyword null-termination
      "\1\0",                      # compression, PNG default (deflate)
      "\0\0",                      # no language tag & translated keyword
      $compressed;                 # data

   $self->add_chunk(iTXt => \$data);
   return;
}
```

The `proper_name()` tries to sanitize the file name removing directories and
stuff that might upset. As everything that has to do with security, it's an
attempt I don't swear on. (It's also used upon extraction, just to be on the
safe side.)

Have fun!

[Perl]: https://www.perl.org/
[A new protocol and tool for PNG file attachments]: https://nullprogram.com/blog/2021/12/31/
[post]: {{ '/2023/03/27/playing-with-png/' | prepend: site.baseurl }}
[`add_iTXt`]: https://codeberg.org/polettix/Romeo/src/commit/d569b84f4e0f0cd9a40b9bebc757b94f284544c2/lib/Romeo/CmdPngMeta/CmdAtCh.pm#L193 
[Romeo]: {{ '/2023/03/07/fun-with-romeo/' | prepend: site.baseurl }}
