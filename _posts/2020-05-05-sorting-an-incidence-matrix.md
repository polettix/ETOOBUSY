---
title: Sorting an incidence matrix
type: post
tags: [ perl ]
comment: true
date: 2020-05-05 23:37:01 +0200
published: true
mathjax: true
---

**TL;DR**

> I needed to sort an incidence matrix lexicographically.

Working on a program to find a design for [Steiner design S(2, 4,
28)][], I needed to work on the input incidence matrices to apply a
constraint programming technique and find a resolution (i.e.
partitioning of matches in rounds).

To ease things, my algorithm assumed that the incidence matrix was
sorted lexicographically. Hence... I needed to do this sorting.

The heart is the following function:

```perl
sub lexi_pass ($M) {
   $M = [
      map            { $_->[1] }
        reverse sort { $a->[0] cmp $b->[0] }
        map          { [join('', $_->@*), $_] } transposed($M)->@*
     ]
     for 1 .. 2;
   return $M;
} ## end sub lexi_pass ($M)
```

It does a sorting pass both by column and by row, in this order. The
sorting is actually always applied by row, but the `transposed` function
switches the roles to work on columns too:

```perl
sub transposed ($M) {
   my $J = $M->[0]->@* - 1;
   my @T;
   for my $i (0 .. $#$M) {
      for my $j (0 .. $J) {
         $T[$j][$i] = $M->[$i][$j];
      }
   }
   return \@T;
} ## end sub transposed ($M)
```

For reasons that I didn't investigate a single pass is not sufficient,
hence I embedded it in a loop to repeat one more pass until we reach a
stable situation. The same function also takes care to read and parse
the input incidence matrix, provided as text:

```perl
sub lexi_parse ($incidence_text) {
   $incidence_text =~ s{\s+\z}{}mxs;
   my $incidence = [map { [split m{}mxs] } split m{\s+}, $incidence_text];
   while ('necessary') {
      $incidence = lexi_pass($incidence);
      my $new = join "\n", map { join '', $_->@* } $incidence->@*;
      return $incidence if $new eq $incidence_text;
      $incidence_text = $new;
   } ## end while ('necessary')
} ## end sub lexi_parse ($incidence_text)
```

After each pass, the incidence matrix text is reconstructed and compared
to the previous iteration. When there is no change, we call it a day and
return.

[Steiner design S(2, 4, 28)]: {{ '/2020/05/04/steiner-2-4-28' | prepend: site.baseurl | prepend: site.url }}

