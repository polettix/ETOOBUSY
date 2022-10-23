---
title: Compactification in NVdB
type: post
series: Passphrases
tags: [ security, text, perl ]
comment: true
date: 2022-10-23 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Enhancing groups in NVdB.

After grouping words to reduce spaces for repetitions, we end up with
wildly different groups. Some of them are singletons, i.e. words that do
not have expansion like week days. Some only contains a few words, like
two, three, or four. Some contain a lot of words.

One additional constraint that we will put in is to consider how many
words that are four, five, or six letters long inside. These will be
considered words that will always be considered good candidates for
selection (contarily to too short or too long words, for which we want
to put a limit as discussed previously).

We can *compactify* these groups to aim for always having *at least*
four such *good* words in each end group. This will allow us to state
that a random choice from any group will add *at least* 2 bits of
entropy (possibly more).

Let's do this in [Perl][]: 

```perl
sub compactify ($groups, $is_good, $threshold = 4) {
   my %good_groups;
   for my $group ($groups->@*) {
      my $n_good = grep { $is_good->($_) } $group->@* or next;
      push $good_groups{$n_good}->@*, [$group->@*];
   }

   my $max = max(keys %good_groups);
   for my $base_size (reverse(1 .. ($threshold - 1))) {
      while ($good_groups{$base_size}->@* > 0) {
         my @new_group      = shift($good_groups{$base_size}->@*)->@*;
         my $new_group_size = $base_size;
         while ($new_group_size < 4) {
            my $companion_size =
              first { ($good_groups{$_} // [])->@* > 0 } 1 .. $max;
            my $companion = shift $good_groups{$companion_size}->@*;
            push @new_group, $companion->@*;
            $new_group_size += $companion_size;
         } ## end while ($new_group_size < ...)
         push $good_groups{$new_group_size}->@*, \@new_group;
         $max = $new_group_size if $max < $new_group_size;
      } ## end while ($good_groups{$base_size...})
   } ## end for my $base_size (reverse...)

   return [map { $_->@* } values %good_groups];
} ## end sub compactify
```

We end up with $1235$ such groups, which means slightly less than $10.3$
bits of entropy. Combined with the additional two bits, it means that
each randomly drawn word would bring at least $12$ bits of entropy --one
more than the XKCD comic!

The end result can be seen [in this file][].

Stay safe!

[Perl]: https://www.perl.org/
[in this file]: https://codeberg.org/polettix/pass4me/src/branch/main/pass4me-groups.json
