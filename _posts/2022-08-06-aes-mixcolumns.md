---
title: AES - MixColumns
type: post
tags: [ aes, security, perl ]
series: A toy AES implementation
comment: true
date: 2022-08-06 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> The `MixColumns` transformation of [AES][], in [Perl][].

With the help of the `GF_2_8_mult` function from [last post][], we're
now ready to code `mix_columns`:

```perl
sub mix_columns ($state) {
   state $indexes_for = [[0 .. 3], [4 .. 7], [8 .. 11], [12 .. 15]];
   state $two         = "\x02";
   state $three       = "\x03";
   for my $if ($indexes_for->@*) {
      $state->@[$if->@*] = (
         GF_2_8_mult($two, $state->[$if->[0]])
           ^ GF_2_8_mult($three, $state->[$if->[1]]) ^ $state->[$if->[2]]
           ^ $state->[$if->[3]],
         $state->[$if->[0]] ^ GF_2_8_mult($two, $state->[$if->[1]])
           ^ GF_2_8_mult($three, $state->[$if->[2]]) ^ $state->[$if->[3]],
         $state->[$if->[0]] ^ $state->[$if->[1]]
           ^ GF_2_8_mult($two,   $state->[$if->[2]])
           ^ GF_2_8_mult($three, $state->[$if->[3]]),
         GF_2_8_mult($three, $state->[$if->[0]]) ^ $state->[$if->[1]]
           ^ $state->[$if->[2]] ^ GF_2_8_mult($two, $state->[$if->[3]])
      );
   } ## end for my $if ($indexes_for...)
   return $state;
} ## end sub mix_columns ($state)
```

It's probably a bit of *anti-climax* at this point, because it's just a
bunch of operations.

The constants `$two` and `$three` are the *characters* `"\x02"` and
`"\x03"` because this is how we represent stuff. The summation
operation, we know, is just the XOR.

> As we already know that we're dealing just with strings, it's not
> strictly necessary to use `^.`. I know, I should for readability and
> documenting reasons.

The inverse function *looks* more complicated, but just because there's
no multiplying by 1 so we have to take all four multiplications in each
of the four formulas:

```perl
sub inv_mix_columns ($state) {
   state $indexes_for = [[0 .. 3], [4 .. 7], [8 .. 11], [12 .. 15]];
   state $_0e         = "\x0e";
   state $_0b         = "\x0b";
   state $_0d         = "\x0d";
   state $_09         = "\x09";
   for my $if ($indexes_for->@*) {
      $state->@[$if->@*] = (
         GF_2_8_mult($_0e, $state->[$if->[0]])
           ^ GF_2_8_mult($_0b, $state->[$if->[1]])
           ^ GF_2_8_mult($_0d, $state->[$if->[2]])
           ^ GF_2_8_mult($_09, $state->[$if->[3]]),
         GF_2_8_mult($_09, $state->[$if->[0]])
           ^ GF_2_8_mult($_0e, $state->[$if->[1]])
           ^ GF_2_8_mult($_0b, $state->[$if->[2]])
           ^ GF_2_8_mult($_0d, $state->[$if->[3]]),
         GF_2_8_mult($_0d, $state->[$if->[0]])
           ^ GF_2_8_mult($_09, $state->[$if->[1]])
           ^ GF_2_8_mult($_0e, $state->[$if->[2]])
           ^ GF_2_8_mult($_0b, $state->[$if->[3]]),
         GF_2_8_mult($_0b, $state->[$if->[0]])
           ^ GF_2_8_mult($_0d, $state->[$if->[1]])
           ^ GF_2_8_mult($_09, $state->[$if->[2]])
           ^ GF_2_8_mult($_0e, $state->[$if->[3]])
      );
   } ## end for my $if ($indexes_for...)
   return $state;
} ## end sub inv_mix_columns ($state)
```

Aaaaand another brick is in place.

Stay safe and tuned for more!

[Perl]: https://www.perl.org/
[AES]: https://csrc.nist.gov/csrc/media/publications/fips/197/final/documents/fips-197.pdf
[Cryptopals]: {{ '/2022/07/10/cryptopals/' | prepend: site.baseurl }}
[last post]: {{ '/2022/08/05/gf28-multiplications/' | prepend: site.baseurl }}
