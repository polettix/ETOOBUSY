---
title: Expanding nouns and adjectives in NVdB
type: post
tags: [ security, text, perl ]
comment: true
date: 2022-10-19 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Expanding nouns and adjectives in [Nuovo vocabolario di base][nvdb].

After expanding verbs, it's just *right* to turn towards other words
that can be *inflected* (is this a verb?) in Italian: nouns (some, at
least) and adjectives.

As a rule of thumb, *common* nouns of *stuff* that can appear in female
or male forms have different inflections, as well as singular and
plural. This can bring a whopping 2 additional bits of entropy to the
lot, which is not bad.

I could not find some ready-made soup like [ian-hamlin/verb-data][repo]
though. That came anyway to the rescue, because it contains a pointer to
the source of its data: the [Wiktionary][wikt].

How I managed to get the data from there will be hopefully elaborated in
some other post. Here, it suffices to say that I saved a file with lines
like this (*gatto* is the singular male form of *cat*):

```
gatto;type=sost;gender=m;pf=gatte;pm=gatti;sf=gatta;sm=gatto
```

This line includes all available inflected forms for **s**ingular,
**p**lural, **f**emale and **m**ale. With this at hand, we can build a
similar expansion like for verbs:

```perl
sub load_spmf_expansions ($set_for, $filename) {
   for my $line (path($filename)->lines_utf8) {
      $line =~ s{\A\s+|\s+\z}{}gmxs;

      my ($main, @pairs) = split m{;}mxs, $line;

      my %kv = map {
         my ($key, @values) = map { lc }
           grep { length $_ && $_ =~ m{[a-z]}imxs }
           map { s{\A\s+|\s+\z}{}rgmxs } split m{[=,]}mxs, $_;
         $key => \@values;
      } grep { /=/ } @pairs;

      my @additional;
      for my $key (qw< pf sf pm sm >) {
         my $values = $kv{$key} or next;
         push @additional, $values->@*;
      }

      my @matches = grep { exists $set_for->{$_} } ($main, @additional)
        or next;

      # duplicates are OK
      add_related($set_for, @matches, $main, @additional);
   } ## end for my $line (path($filename...))
   return $set_for;
} ## end sub load_spmf_expansions
```

This time we're doing the expansion in reverse order: we read each
candidate expansion and *then* match each possible alternative against
the available words (which come from the verbs expansion).

Here we start to get a glimpe about *why* we're using a hash for
tracking words: it's easy to look for them in these cases. Additionally,
it allows us to "associate" some verb forms with candidate nouns (many
present and past participles are used as such). Why I want to keep them
"related" will be cleared in some future post.

If we have *any* match, then the expansions can be added. I'm not 100%
sure it's the best thing to do, but it seems a good first-pass
approximation so far.

Stay safe!


[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[nvdb]: https://www.internazionale.it/opinione/tullio-de-mauro/2016/12/23/il-nuovo-vocabolario-di-base-della-lingua-italiana
[repo]: https://github.com/ian-hamlin/verb-data
[wikt]: https://en.wiktionary.org/wiki/Wiktionary:Main_Page
