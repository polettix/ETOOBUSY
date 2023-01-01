---
title: PWC166 - K-Directory Diff (Raku solution)
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-05-26 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> A [Raku][] addendum to [TASK #2][] from [The Weekly Challenge][]
> [#166][]. Enjoy!

The algorithm is explained in previous post [PWC166 - K-Directory
Diff][ppost]. *'nuff said*.

```raku
#!/usr/bin/env raku
use v6;

put k-directory-diff(< dir_a dir_b dir_c >);

sub k-directory-diff (*@dirs) {
   my @lists = select-incompletes(@dirs.map({list-from($_)}));
   for @lists Z @dirs -> ($l, $d) { $l.unshift: $d }
   return render-columns(@lists);
}

sub list-from ($dir) {
   $dir.IO.dir.map({.basename ~ (.d ?? '/' !! '') }).Array
}

sub select-incompletes (@lists) {
   my (@retval, @sets);
   my $union = SetHash.new;
   my $intersection = SetHash.new(@lists[0].Slip);
   for @lists -> $list {
      my $set = set(@$list);
      $union ∪= $set;
      $intersection ∩= $set;
      @sets.push: $set;
      @retval.push: [];
   }
   for $union.keys.sort({$^a cmp $^b}) -> $item {
      next if $item ∈ $intersection;
      for @retval Z @sets -> ($r, $s) {
         $r.push($item ∈ $s ?? $item !! '');
      }
   }
   return @retval;
}

sub render-columns (@columns) {
   my @widths = @columns.map({$_».chars.max});
   my $format = @widths.map({"%-{$_}s"}).join(' | ');
   my $separator = $format.sprintf(@widths.map({'-' x $_}));
   my ($head, @retval) = (^@columns[0].elems).map(-> $i {
      $format.sprintf(@columns.map({$_[$i]}));
   });
   ($head, $separator, |@retval).join("\n");
}
```

The [IO::Path][] thing is very handy. We have to add the trailing `/`
character by the rules, otherwise the `list-from` function might be even
shorter.

The `select-incompletes` follows the same algorithm as the [Perl][]
implementation, showing off the presence of a *set* implementation and
support for Unicode characters for union, intersection, and test for an
element belonging to the set. The availability of the `Z` operator is
also very handy!

The rendering function is pretty much a translation too. As usual with
[Raku][], I didn't get it right from the beginning, because the
`@retval` needs to be *slipped* before feeding it into `join`. Whatever.

So... stay safe everybody!

[ppost]: {{ '/2022/05/25/pwc166-k-directory-diff/' | prepend: site.baseurl }}
[Raku]: https://www.raku.org/
[IO::Path]: https://docs.raku.org/type/IO::Path
[Perl]: https://www.perl.org/
[The Weekly Challenge]: https://theweeklychallenge.org/
[#166]: https://theweeklychallenge.org/blog/perl-weekly-challenge-166/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-166/#TASK2
