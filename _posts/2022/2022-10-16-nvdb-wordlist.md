---
title: Extract words from the NVdB PDF file
type: post
series: Passphrases
tags: [ security, text, perl ]
comment: true
date: 2022-10-16 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Getting the list of words out of the [Nuovo vocabolario di
> base][nvdb].

The [Nuovo vocabolario di base][nvdb] is in PDF form and is arranged as
a list that is more or less like this:

```
1a s.f. e m.inv., 2a prep., abbagliante p.pres., agg., s.m., abbaiare
v.intr. e tr., abbandonare v.tr., abbandonato p.pass., agg., s.m.,
abbandono s.m., abbassare v.tr., abbasso avv., inter., abbastanza avv.,
...
```

The first step is extracting the list of words. It's easy to copy the
whole list into a text-only file, but we can use some [Perl][] to remove
all the cruft. Here's my take on this:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use English qw< -no_match_vars >;

my $filename = shift // 'vocabolario-di-base-input.txt';

my $text = do {
   open my $fh, '<:encoding(Latin1)', $filename
      or die "open('$filename'): $OS_ERROR\n";
   local $/;
   <$fh>;
};

$text =~ s{^\s*[A-Z]\s*[\r\n]*}{, }gmxs;
$text =~ s{ -[\r\n] }{}gmxs;
$text =~ s{ [\r\n]+ }{ }gmxs;

binmode STDOUT, ':encoding(UTF-8)';
my $last = '';
for (split m{ , \s* }mxs, $text) {
   my ($word) = m{\A \d* (\w+) \s+\S}mxs or next;
   say $word if $word ne $last;
   $last = $word;
}
```

There's some heuristic involved, I hope it's all correct!

- Different letters are marked in a single line by itself. One
  substitution gets rid of them, putting a comma character `,` just to
  make a single, long list of items.

```perl
$text =~ s{^\s*[A-Z]\s*[\r\n]*}{, }gmxs;
```

- Some words are hyphenated and split into two parts, to put a newline.
  We want to reconstruct the original word, so we get rid of the hypens
  and newlines:

```perl
$text =~ s{ -[\r\n] }{}gmxs;
```

- Then, we put the whole list on a single line, removing newlines and
  putting a space instead:

```perl
$text =~ s{ [\r\n]+ }{ }gmxs;
```

- We're now ready to go through the list, using the comma and all
  following spaces as separator. Each item can start with an optional
  number, then our target word, then something else. Hence, we can get
  the word with a regular expression:

```perl
my ($word) = m{\A \d* (\w+) \s+\S}mxs or next;
```

- Some words might appear multiple times because they have different
  meanings or types (this is where the numbers come into play). We don't
  want these duplicates, so we just filter them out:

```perl
say $word if $word ne $last;
$last = $word;
```

Let's put it at work:

```
a
abbagliante
abbaiare
abbandonare
abbandonato
abbandono
abbassare
abbasso
abbastanza
...
```
This gives us 7176 items, which I think is a good starting point.

Stay safe!

[Perl]: https://www.perl.org/
[nvdb]: https://www.internazionale.it/opinione/tullio-de-mauro/2016/12/23/il-nuovo-vocabolario-di-base-della-lingua-italiana
