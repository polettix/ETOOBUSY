---
title: Parsing fixed-format lines
type: post
tags: [ perl, parsing, text processing ]
comment: true
date: 2021-10-12 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Some notes about parsing fixed-format lines in [Perl][].

In last post [Resuming Data::Tubes][] I discussed a bit about a pipeline
to parse a file that had *dispositions* of data, each composed of a
sequence of *fixed-format lines* (called *records*).

For these lines, there's [a document][] (sorry... Italian only!)
explaining the meaning of each line type, but the gist is that:

- only a bunch of characters are allowed, encoded either in ASCII or in
  EBCDIC ([this document][]'s appendix A has it all).
- each line is always exactly 120 bytes/characters long, whose character
  index starts at 1.
- each line has its own *type* that always appears in the same position
  in the field, i.e. positions 2 to 3 (two characters).
- everything that follows is record/line type specific.

Some aggregates of records are grouped together depending on what is
being transferred. As an example, a specific type of disposition is
composed of 7 records, collectively holding all the info that is needed
for the disposition.

In this case, the lines share some additional partial information - i.e.
a "disposition local identifier" from character 4 to character 10 - then
they restart holding type-specific data.

To address the parsing of these lines, I found it useful to define the
mapping of the structure of each record type to the position of the
sub-fields I was interested into:

```perl
state $parser_for = {
   IM => {
      data => 's 14-19',
   },
   10 => {
      progressivo => 'n 4-10',
      'data-creazione' => 's 11-16',
      'data-valuta' => 's 17-22',
      causale => 'n 29-33',
      'importo-centesimi' => 'n 34-46',
      segno   => 's 47',
      riferimento => 's 58-69',
      'conto-creditore' => 'n 80-91',
   },
   14 => {
      progressivo => 'n 4-10',
      data => 's 23-28',
      importo => 'n 34-46',
      segno => 'n 47',
      cliente => 's 98-113',
   },
   ...
```

My parsing instructions are simple: `n` means numeric (where I remove
leading `0` characters) and `s` means string (where I trim trailing
spaces). A single integer means a single character, otherwise it's
ranges (usually one, possibly many). Hence, after detecting the record
type, I do the parsing like this:

```perl
while (my ($key, $value) = each $parser_for->{$type}->%*) {
   my ($ft, @ranges) = split m{\s+}mxs, $value;
   $parsed{$key} = '';
   for my $range (@ranges) {
      my ($start, $stop) = split m{-}mxs, $range;
      $stop //= $start;
      $start--;
      $parsed{$key} .= substr $line, $start, $stop - $start;
   }
   $parsed{$key} =~ s{\A0+}{}mxs if $ft eq 'n';
   $parsed{$key} =~ s{\s+\z}{}mxs if $ft eq 's';
}
```

The `$start` variable is decreased by one to account for the fact that
strings are indexed starting at 0 in [Perl][]. Variable `$stop` does not
need this adjustment because it is supposed to point to the position
immediately after the last character to extract with `substr`, which it
already does!

So, here it is... my dumb-simple approach to parsing fixed-format lines.
What would be yours?


[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[a document]: https://www.adpersonam.pr.it/download/allegati/fn000323.pdf
[this document]: https://ib.cbibanking.it/helpcenter/export/sites/default/helpcenter/Documenti_condivisi/modulistica/CBI-STD-001_6_07.pdf
[Resuming Data::Tubes]: {{ '/2021/10/11/resuming-data-tubes/' | prepend: site.baseurl }}
