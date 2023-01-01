---
title: AES - Key stuff
type: post
tags: [ aes, security, perl ]
series: A toy AES implementation
comment: true
date: 2022-08-07 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Key Expansion and usage within [AES][], in [Perl][].

Protection in [AES][] is provided by the (shared) key, which is a
variable-length amount of hopefully randomish data. The key lengths
allowed by the standard are 128 bits (i.e. 16 octets), 192 bits (24
octets), and 256 bits (32 octets).

For the purposes of the algorithm, the key is *expanded* into a longer
sequence of bits, deterministically. Think of it like you have a random
number generator, and you use the key to set it in a specific state from
which you draw the bits that are needed by the other moving parts of the
algorithm.

The [Perl][] code to implement the key expansion algorithm is the
following:

```perl
sub key_expansion ($key) {
   state $Nb = 4;

   my $Nk = length($key) / $Nb;
   my $Nr = $Nk + 6;
   my @w;

   # bootstrap @w copying the key
   push @w, substr $key, $Nb * $_, $Nb for 0 .. $Nk - 1;

   my $rcon0 = "\x01";
   while (@w < $Nb * ($Nr + 1)) {
      my $i_mod_Nk = @w % $Nk;
      my $temp     = $w[-1];
      if ($i_mod_Nk == 0) {
         $temp = sub_word(rot_word($temp)) ^ ($rcon0 . ("\x00" x 3));
         $rcon0 = GF_2_8_mult($rcon0, "\x02");
      }
      elsif ($Nk > 6 && $i_mod_Nk == 4) {
         $temp = sub_word($temp);
      }
      push @w, $w[-$Nk] ^ $temp;
   } ## end while (@w < $Nb * ($Nr + ...))

   my @schedule;
   push @schedule, join '', splice @w, 0, 4 while @w;
   return \@schedule;
} ## end sub key_expansion ($key)
```

The *word length* `$Nb` is fixed in AES to 32 bits, or 4 octets. It
should probably belong to a common constant, here we're getting it as a
state variable so that we don't re-initialize it all the times.

Depending on the key length, [AES][] operates in *rounds* over the data;
each round needs its *word* of data from the key, so we have to expand
it as much as to cover all the rounds. Variable `$Nr` keeps the value of
how many rounds we have to cover (here I'm just using a *magic number*,
adding `6` to the number of words in the key `$Nk`).

The `sub_word` and `rot_word` functions used in the loop are simple
manipulations over *words*. The former applies the same operation as
`sub_bytes` over the word itself, the latter is just taking the last
octet and placing it in the front.

```perl
sub sub_word ($word) { join '', sub_bytes([split m{}mxs, $word])->@* }

sub rot_word ($word) { substr($word, 1) . substr($word, 0, 1) }
```

This function lets us transform the key into a *key schedule*, which
will then come handy when we will put all pieces together. In
particular, it will be used to feed the second parameter to another key
aspect (pun intended!) of the algorithm, i.e. AddRoundKey:

```perl
sub add_round_key ($state, $key) {
   my @key = split m{}mxs, $key;
   $state->[$_] ^= $key[$_] for 0 .. $state->$#*;
   return $state;
}
```

As we will see, at each round we will take a piece from the key schedule
and use it to perform a transformation on the input data, using
`add_round_key`. The inverse function is the same as `add_round_key`, so
there's no need to code it.

One last interesting bit is the *key schedule modification*, which will
come handy in coding the inverse ciphering algorithm. It's a procedure
that modifies the key schedule so that *things* appear in the right
place at the right time:

```perl
sub modify_key_schedule_copy ($s) { modify_key_schedule_inplace([$s->@*]) }

sub modify_key_schedule_inplace ($schedule) {
   for my $kid (1 .. $schedule->$#* - 1) {    # work on mid stuff only
      my $imc = inv_mix_columns([split m{}mxs, $schedule->[$kid]]);
      $schedule->[$kid] = join '', $imc->@*;
   }
   $schedule->@* = reverse $schedule->@*;
   return $schedule;
} ## end sub modify_key_schedule_inplace ($schedule)
```

There are two versions, one that *destroys* the original key,
substituting it with the modified schedule, and the other one that
produces a copy.

Stay safe!

[Perl]: https://www.perl.org/
[AES]: https://csrc.nist.gov/csrc/media/publications/fips/197/final/documents/fips-197.pdf
[Cryptopals]: {{ '/2022/07/10/cryptopals/' | prepend: site.baseurl }}
[last post]: {{ '/2022/08/05/gf28-multiplications/' | prepend: site.baseurl }}
