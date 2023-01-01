---
title: Expanding verbs in NVdB
type: post
series: Passphrases
tags: [ security, text, perl ]
comment: true
date: 2022-10-18 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Expanding verbs from [Nuovo vocabolario di base][nvdb].

In recent post [Expanding words in NVdB][] I introduced the idea of
finding *variants* for basic words as found in [Nuovo vocabolario di
base][nvdb], so that we can get more entropy bits and hopefully get rid
of longer words in exchange.

Verbs can provide a good deal of alternative forms, as we saw. It's
actually much more than that, because every tense usually adds new
words. On the other hand, I decided to *avoid* less "direct" tenses
(like *condizionale* and *congiuntivo*) to keep the spirit of *very wide
usage* of the starting *vocabolario*.

To do the expansion, I started from this repository:
[ian-hamlin/verb-data][repo]. It's actually an extraction from the
[Wiktionary][wikt], and a pretty useful one I daresay because everything
is neaty put into consistent JSON files.

The basic reasoning is simple: for every word in the starting list, see
if there's a verb in the wiktionary and, in case, expand the word using
*some* variations (not all, because some are composite and we want to
avoid them). So I ended up with this:

```perl
sub load_verb_expansions ($set_for, $filename) {
   state $is_interesting_group = {
      map { $_ => 1 }
        qw<
        infinitive
        gerund
        presentparticiple
        pastparticiple
        indicative/present
        indicative/imperfect
        incative/pasthistoric
        indicative/future
        >
   };
   my $record_for = decode_json(path($filename)->slurp_raw);

   for my $word (keys $set_for->%*) {
      DEBUG "verb<$word>";
      my $record = $record_for->{$word} or next;
      my @words  = grep { !m{\W}mxs }
        map  { split m{(,\s*)+}mxs, $_->{value} =~ s{\A\s+|\s+\z}{}rgmxs }
        grep { $is_interesting_group->{$_->{group}} }
        $record->{conjugations}->@*;
      DEBUG " --> words(@words)";
      add_related($set_for, $word, @words) if @words;
   } ## end for my $word (keys $set_for...)

   return $set_for;
} ## end sub load_verb_expansions
```

We'll discuss the data model in due time, it suffices to say that
`$set_for` contains one hash for each word from the vocabulary that
we're interested into, so we iterate over its keys to get back to the
words. `$filename` is the path to the file where all verbs forms have
been collected, and `add_related` is a way to add these new words in the
`$set_for` hash.

Stay safe!


[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[nvdb]: https://www.internazionale.it/opinione/tullio-de-mauro/2016/12/23/il-nuovo-vocabolario-di-base-della-lingua-italiana
[Expanding words in NVdB]: {{ '/2022/10/17/nvdb-expansions/' | prepend: site.baseurl }}
[repo]: https://github.com/ian-hamlin/verb-data
[wikt]: https://en.wiktionary.org/wiki/Wiktionary:Main_Page
