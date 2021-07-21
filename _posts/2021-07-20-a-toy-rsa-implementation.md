---
title: A toy RSA implementation
type: post
tags: [ perl, security, coding ]
comment: true
date: 2021-07-20 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> I had fun with a toy implementation of [RSA][].

**DISCLAIMER: this is a TOY implementation! Don't use it for anything
serious!**

I was reading through [What every computer science major should know][]
and came to this:

> RSA is [easy enough to implement][] that everyone should do it.

Well, it turns out that doing a *toy implementation* (i.e. an
implementation that grasps the basics of the algorithm, but lacks a ton
of additional insights that a proper, robust implementation MUST take
into account) is very straightforward.

If you're curious about the underlying maths, I think that [RSA - theory
and implementation][] is a fair description of the topic, so I will not
repeat it here.

Here's my implementation:

```perl
package ToyRSA;
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use Math::BigInt;

sub toy_rsa_keys ($p, $q) {
   ($p, $q) = map { Math::BigInt->new($_) } ($p, $q);
   my $n = $p * $q;             # "big unfactorable" number
   my $T = $n - $q - $p + 1;    # totient (p - 1) * (q - 1)

   my $e = Math::BigInt->new(0x10001);    # try this first
   $e = ($e >> 1) | 1 while $e >= $T || Math::BigInt::bgcd($e, $T) != 1;
   $e += 2 while $e < 2 || Math::BigInt::bgcd($e, $T) != 1;
   die "wtf?!?\n" if $e >= $T;

   return ([$e, $n], [$e->copy->bmodinv($T), $n]);
} ## end sub toy_rsa_keys

sub toy_rsa_apply ($m, $key) {
   die "too low stuff!\n" if $m >= $key->[1];    # m >= n
   return Math::BigInt->new($m)->bmodpow($key->@*);
}

sub to_hex ($x) { Math::BigInt->new($x)->as_hex }
sub print_key ($name, $key) {
   my ($mod, $n) = map { to_hex($_) } $key->@*;
   say "$name";
   say "   mod: $mod";
   say "     n: $n";
}

exit sub (
   $cleartext = 42,
   $p         = '170141183460469231731687303715884105727',
   $q         = '43143988327398957279342419750374600193',
  )
{
   my ($public, $private) = toy_rsa_keys($p, $q);
   print_key(private => $private);
   print_key(public => $public);

   my $encrypted = toy_rsa_apply($cleartext, $private);
   my $decrypted = toy_rsa_apply($encrypted, $public);
   say "encrypted: @{[to_hex($encrypted)]}";
   say "decrypted: @{[to_hex($decrypted)]}";
   say "cleartext: @{[to_hex($cleartext)]}";
}->(@ARGV) unless caller;

1;
```

It's been a bit *anti-climax* to discover that [Math::BigInt][] is
actually *already* shipped with every operation that we need for the
algorithm:

- support for arbitrarily long integers;
- finding the inverse of an integer modulo another integer (`bmodinv`);
- calculating the power of two integers, modulo a third one (`bmodpow`).

It also supports calculating the greatest common divisor between two
integers, which comes handy to find a suitable *public* modulo (in most
practical implementation it is already set to decimal `65537`, i.e.
hexadecimal `0x10001`).

It turns out that the most *complicated* thing is precisely finding out
a public modulo that is *compatible* with the choice of the input
"large" primes `$p` and `$q`:

```perl
my $e = Math::BigInt->new(0x10001);    # try this first
$e = ($e >> 1) | 1 while $e >= $T || Math::BigInt::bgcd($e, $T) != 1;
$e += 2 while $e < 2 || Math::BigInt::bgcd($e, $T) != 1;
die "wtf?!?\n" if $e >= $T;
```

We start from the *usual choice* (i.e. `65537`). As I understand it,
this choice simplifies calculations because it has only two bits set (as
it is evident from its hexadecimal representation `0x10001`).

Then, we have to make sure that the candidate is both less than and
coprime with the *totient* value (that is $(p-1)(q-1)$ in our case). If
`$p` and `$q` are sufficiently large, then `65537` will be fine because
it will be less than the totient and surely coprime with it (because it
is a prime number!).

If our input primes `$p` and `$q` are *too low*, though, we have to find
out a different candidate for `$e`. This is what this line aims to:

```perl
$e = ($e >> 1) | 1 while $e >= $T || Math::BigInt::bgcd($e, $T) != 1;
```

At each iteration, `$e` is shifted one position to the right, then made
odd again. This means that e.g. the starting value `0x10001` becomes
`0x8001`, i.e. in binary:

```
0x10001 -> 1 0000 0000 0000 0001
0x08001 -> 0 1000 0000 0000 0001
```

The new candidate is *lower* than the previous one (which is good for
comparing it against the *totient*), odd (which we are required to
guarantee) and "simple" (only two bits set), so we test if it is a good
one by:

- comparing it against the totient `$T`, and
- making sure it is coprime with `$T` (the new candidate is not
  guaranteed to be prime).

We might end up having `$e` equal to `1`, which is *not* good because
its inverse is... `1`, which would mean *no encryption*. For this corner
case, we have the following line:

```
$e += 2 while $e < 2 || Math::BigInt::bgcd($e, $T) != 1;
```

This iterates through all odd numbers until we find one that is co-prime
with the totient `$T`. Crude but effective.

If after all of this we *still* land on something bigger than, or equal
to the totient value `$T`... it means that our input `$p` and `$q` are
*really low* (i.e. `2` and `3`) and we bail out.

One final implementation node, when calculating the private key we have
to find the *inverse of `$e` modulo `$T`*. As said, [Math::BigInt][]
covers it with `bmodinv`, **but** this is an operation performed *on the
object*, i.e. this:

```
$e->bmodinv($T)
```

would *change `$e`* setting it to the inverse modulo `$T`. To avoid
this, then, we use `copy`:

```
return ([$e, $n], [$e->copy->bmodinv($T), $n]);
```

One last consideration... this kind of *anti-climax* moment when you
discover that your language supports stuff out of the box... are
**awesome** 😍


[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[RSA]: https://en.wikipedia.org/wiki/RSA_(cryptosystem)
[What every computer science major should know]: https://matt.might.net/articles/what-cs-majors-should-know/
[easy enough to implement]: http://matt.might.net/articles/implementation-of-rsa-public-key-cryptography-algorithm-in-scheme-dialect-of-lisp/
[RSA - theory and implementation]: https://eli.thegreenplace.net/2019/rsa-theory-and-implementation/
[Math::BigInt]: https://metacpan.org/pod/Math::BigInt
