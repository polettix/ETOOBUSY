---
title: Terminal avatars
type: post
tags: [ perl, rakulang, fun ]
comment: true
date: 2023-02-28 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Making avatar generation look better on the terminal

In last post [Simple avatars][] I left with this example:

```
  #  #  
 ##  ## 
##    ##
 # ## # 
# #  # #
  #  #  
# #### #
# #  # #
```

Not exactly *attractive*, right?

So I remembered about addressing this very problem in [Terminal QR Code
with Unicode characters][] (updated by [Reverse printing the QR Code in
the terminal][]), which led to:

![screenshot of avatar]({{ '/assets/images/avathar-polettix.8.png' | prepend: site.baseurl }})

Much better, right?

I also thought that I needed to translate it into [Raku][], so here we
go:

```raku
sub terminalize ($encoded, $reverse = 1) {
   state @direct-char-for = [
      ' ',                       # 0
      "\c[LOWER HALF BLOCK]",    # 1
      "\c[UPPER HALF BLOCK]",    # 2
      "\c[FULL BLOCK]",          # 3
   ];
   state &c2i = sub ($c) { $c eq ' ' ?? 0 !! 1 };

   my @char-for = |@direct-char-for;
   @char-for = @char-for.reverse if $reverse;

   my $first-row-id = 0;
   my @output;
   while ($first-row-id <= $encoded.end) {
      my $first-row = $encoded[$first-row-id++];
      my $second-row =
          $first-row-id <= $encoded.end
        ?? $encoded[$first-row-id++]
        !! [' ' xx $first-row.elems];
      @output.push: (
         (@char-for[0] x 2),
         (0 .. $first-row.end).map({
            my $id = &c2i($first-row[$_]) * 2 + &c2i($second-row[$_]);
            @char-for[$id];
         }),
         (@char-for[0] x 2),
      ).flat.join('');
   } ## end while ($first_row_id <= $encoded...)
   my $blank = S:g/./@char-for[0]/ with @output[0];
   return [$blank, |@output, $blank];
} ## end sub terminalize
```

I'm sure that there's something better than this *crude translation*,
e.g. the `&c2i` subroutine might be a real, lexical subroutine.
Whatever, it works.

Cheers!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Simple avatars]: {{ '/2023/02/27/simple-avatars/' | prepend: site.baseurl }}
[Terminal QR Code with Unicode characters]: {{ '/2021/09/26/text-qrcode-unicode/' | prepend: site.baseurl }}
[Reverse printing the QR Code in the terminal]: {{ '/2022/07/01/cmdline-qrcode-update/' | prepend: site.baseurl }}
