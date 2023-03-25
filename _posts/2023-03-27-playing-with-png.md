---
title: Playing with PNG files
type: post
tags: [ perl, graphics, png ]
comment: true
date: 2023-03-27 06:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Playing with PNG file does not necessarily require a library.

Reading [A new protocol and tool for PNG file attachments][] I figured that
the [PNG specification][] is quite easy to follow and implement, especially
if one does not want to deal with the graphics parts.

I know, I know.

As much as [Perl][] is great for dealing with text, it's great with binary
data too. In the specific case, I only needed to deal with interpreting
lengths expressed as four-byte integers in big-endian arrangement, which is
where [pack][]/[unpack][] shine:

```
my $length = unpack('N', $four_bytes_representation);
my $length_as_bytes = pack('N', $length);
```

There are two other twists that can be easily addressed:

- compression with deflate/inflate. Guess what? [IO::Compress::Deflate][]
  and [IO::Uncompress::Inflate][] hit the nail right in the head and are in
  CORE
- calculating the CRC can be done easily, it's sufficient to translate the C
  code at the end of the [PNG specification][].

The latter, in particular, led me to this:

```
sub png_crc (@data) {
   state $full  = 0xffffffff;
   state $table = [
      map {
         my $c = $_;
         $c = $c & 1 ? (0xedb88320 ^ ($c >> 1)) : ($c >> 1) for 1 .. 8;
         $c;
      } 0 .. 255
   ];

   my $c = $full;
   for my $item (@data) {
      my $dataref = ref($item) ? $item : \$item;
      my $n       = length($$dataref);
      for my $i (0 .. ($n - 1)) {
         my $v = ord(substr($$dataref, $i, 1));
         $c = $table->[($c ^ $v) & 0xff] ^ ($c >> 8);
      }
   } ## end for my $item (@data)
   return pack 'N', $c ^ $full;
} ## end sub png_crc
```

It's a bit more complicated than it needs with the references and stuff, but
just because I like to avoid moving too much data around.

So... if you want to give it a try, it's a nice and easy thing.

Stay safe!


[Perl]: https://www.perl.org/
[A new protocol and tool for PNG file attachments]: https://nullprogram.com/blog/2021/12/31/
[PNG specification]: https://www.w3.org/TR/png/
[pack]: https://perldoc.perl.org/functions/pack
[unpack]: https://perldoc.perl.org/functions/unpack
