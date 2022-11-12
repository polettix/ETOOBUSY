---
title: PWC094 - Group Anagrams
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-01-06 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#094][]. Enjoy!

# The challenge

> You are given an array of strings `@S`. Write a script to group
> Anagrams together in any random order.
>
> > An Anagram is a word or phrase formed by rearranging the letters of
> > a different word or phrase, typically using all the original letters
> > exactly once.

# The questions

I guess that in all these puzzles that invove messing with characters
the first question would be... *what encoding should I consider*? Here
we are basically assuming that our *words* are restricted to the 26
lowercase letters in the latin alphabeth... but is this *actually* the
case?!?

The second thing is... an assumption. I hope we're all good with the
output from [Data::Dumper][] 😅


# The solution

Here is the boring solution that came to mind:

```perl
sub group_anagrams (@S) {
   my %group_for;
   for my $item (@S) {
      my $key = join '',
         sort { $a cmp $b }
         map { lc }
         split m{}mxs, $item;
      push $group_for{$key}->@*, $item;
   }
   return [values %group_for];
}
```

Well... maybe not exactly *boring*, because there's a lot going on.

We iterate over all input strings, using `$item` as the iteration
variable.

Then, our goal is to find out a *key* that will be *common* to all words
that belong to the same set but will be *different* from the *key*
of words in any other set.

One way to do this is to rearrange all letters in the specific word in
lexicographic order. In this way we will have a sort of *fake anagram*,
a possibly inexistent word that shares the same letters as the word in
`$item`.

To do this, we...

- divide `$item` in a list of characters via `split`;
- make sure all characters are lowercase (I suspect that we should aim
  for some *fold case* here but I'll not be too picky);
- sort the resulting lowercased characters lexicographically;
- merge these characters back into a string.

This gives us `$key`. At this point, we just add this new `$item` to an
array where we keep all anagrams of this `$key`.

The last thing we have to do is... return all such arrays, and we're
done!

If you want to play with the whole thing... here it is:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use Data::Dumper; $Data::Dumper::Indent = 1;

sub group_anagrams (@S) {
   my %group_for;
   for my $item (@S) {
      my $key = join '',
         sort { $a cmp $b }
         map { lc }
         split m{}mxs, $item;
      push $group_for{$key}->@*, $item;
   }
   return [values %group_for];
}

say Dumper group_anagrams(@ARGV);
```

Stay safe!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#094]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-094/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-094/#TASK1
[Perl]: https://www.perl.org/
[Data::Dumper]: https://metacpan.org/pod/Data::Dumper
