---
title: Grouping in NVdB
type: post
series: Passphrases
tags: [ security, text, perl ]
comment: true
date: 2022-10-22 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> This might be controversial: grouping words after expansions.

Let's see where we are now in this series:

- I like [Passphrases][] and I'd like them to be more widespread
- To this end, I think that using words that people find relatable is
  crucial. No, I don't have any study to point to, just the fact that
  the contrary didn't work well because most people tried to fit
  something memorable in their passwords, and I can only guess we
  remember better things we know.
- For Italian, I looked at [Nuovo vocabolario di base della lingua
  italiana][] to take inspiration for a good starting list
- Later I went down the [Expanding words in NVdB][] rabbit hole to
  expand the list of words (and the possible entropy) without
  sacrificing the breadth of how much these words are known around.

At this point I managed to move from $7176$ up to a whopping $44160$
distinct words. This is $15.4$ bits of entropy per word, yay!

Well, not so fast.

First of all, how good would be a password like
`gatta.gatto.gatti.gatte`? I'm not particularly fond of it:

- it's lame and something that a human might definitely land on of left
  on their own "randomness"
- it's even slightly difficult to remember. What order did I put them?
  Wait, no, maybe it was male first? Or plural?

Additionally, many of those words might be very short (one to three
letters) or long (seven or more letters). I wouldn't like a password
like `a.e.i.o` (which would be possible), and most people would refuse
to use `nasceranno.svegliandosi.giardinaggio.identificazione` (52
characters). Heck, **I** would refuse it too!

Hence, my proposal is to *group* words that are similar, remove a group
after it's been used once, and choose randomly inside a group according
to some algorithm that limits the number of short *and* long words that
can be admitted in a password.

Here's where the sets come handy. The data structure `$set_for` keeps
one key for each word, pointing to another hash that is used as a set
(words are keys in the set, all pointing to a conventional `1` that is
unused). Here's how it is initialized:

```perl
my $set_for = {map { lc($_) => {lc($_) => 1} } list_of_words_...
```

Each expansion adds new words, making sure to keep the relation across
each single expansion. So, for example, `gatto` will end up in the set
for `gatta` and vice-versa. The details are in the following function,
which is used by both expansion functions we saw in previous posts:

```perl
sub add_related ($set_for, $first, @other_words) {
   $first = lc $first;
   my $root = $set_for->{$first} // die "WTF?!?";
   DEBUG "   add_related: starting from <$first><$root>";
   for my $w (@other_words) {
      my $word = lc $w;
      DEBUG "   add_related: analysing <$word>";
      if (my $wroot = $set_for->{$word}) {
         DEBUG "   add_related:    wroot<$wroot>";
         next if refaddr($root) eq refaddr($wroot);    # already merged
         ($root, $wroot) = ($wroot, $root) # swap if...
           if scalar(keys $root->%*) < scalar(keys $wroot->%*);
         for my $item (keys $wroot->%*) {
            $root->{$item}    = 1;
            $set_for->{$item} = $root;
         }
      } ## end if (my $wroot = $set_for...)
      else {
         DEBUG "   add_related: NEW SET";
         $set_for->{$word} = $root;
         $root->{$word}    = 1;
      }
   } ## end for my $w (@other_words)
} ## end sub add_related
```

Instead of creating separate sets, we merge them into one and point both
words to it.

After the two expansions, some words might appear in multiple otherwise
unrelated sets, so we can remain on the safe side and merge them all.
This will end up in a *partition* of the whole set of words, and it's
what the following function does:

```perl
sub sets_to_groups ($sets) {
   my @groups;
   my %seen;
   for my $set (values $set_for->%*) {
      next if $seen{refaddr($set)}++;

      my @words = sort { $a cmp $b }
        grep { !m{[^a-z]}mxs } keys $set->%*;
      next unless @words;

      push @groups, \@words;
   } ## end for my $set (values $set_for...)
   return \@groups;
}
```

All words are actually already in the same sets if related, so we just
have to detect the separated ones. This is where `refaddr` comes into
play, as it allows us to figure out if two "sets" are (exactly) the
same.

After passing through `sets_to_groups`, we end up with an array of
arrays, each containing a list of one of the groups. And... there are
$6090$ such groups.

We'll call them... *raw groups*. For reasons that will be discussed at
due time.

Stay safe!

[Perl]: https://www.perl.org/
[Expanding words in NVdB]: {{ '/2022/10/17/nvdb-expansions/' | prepend: site.baseurl }}
[Nuovo vocabolario di base della lingua italiana]: {{ '/2022/10/15/nvdb/' | prepend: site.baseurl }}
[Passphrases]: {{ '/2022/10/10/passphrases/' | prepend: site.baseurl }}
