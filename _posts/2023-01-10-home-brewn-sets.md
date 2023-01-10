---
title: Home-brewn sets
type: post
tags: [ perl, coding ]
comment: true
date: 2023-01-10 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Some benchmarks on different ways of implementing (little) sets.

A [Set][] is (among other things):

> an abstract data type that can store unique values, without any
> particular order.

(taken from the linked Wikipedia page).

In other terms, it holds a collection of items, each being "unique", and
is capable of answering questions like *does this item belong to the
set?* and the like.

This is often very useful to have at hand, especially when you're
solving coding puzzles 🙄

My default go-to solution for implementing a set operation in [Perl][]
is by means of a *hash*. If we ignore the *values*, we basically have a
useful impelementation of a set for strings:

```perl
my @items = qw< foo bar baz foo hey >;  # note: foo is duplicated!
my %set = map { $_ => 1 } @items;

say $_, ': ', $set{$_} ? 'inside' : 'outside'
    for qw< foo whatever hey you >;
```

The code above prints:

```
foo: inside
whatever: outside
hey: inside
you: outside
```

There can be *a lot of variations*, even by just using hashes. As an
example, how are we going to initialize the hash with the elements? Two
examples:

```perl
use constant NEVER  => 7;
use constant ALWAYS => 9;

...

sub by_hash (@input) {
   my %set = map { $_ => 1 } @input;
   $set{$input[rand @input]} or die 'fail in provided element';
   $set{+ALWAYS} or die 'fail on ALWAYS';
   $set{+NEVER} and die 'fail on NEVER';
}

sub by_hash2 (@input) {
   my %set;
   @set{@input} = (1) x @input;
   $set{$input[rand @input]} or die 'fail in provided element';
   $set{+ALWAYS} or die 'fail on ALWAYS';
   $set{+NEVER} and die 'fail on NEVER';
}
```

And more: is it better to use a check on the value, or use `exists`?

On the other hand... this flexibility *might* come to a cost. What if we
need to check something more restricted, but *a lot of times*? We might
remap our elements onto integers, and use arrays instead:

```perl
sub by_array (@input) {
   my @set;
   $set[$_] = 1 for @input;
   $set[$input[rand @input]] or die 'fail in provided element';
   $set[ALWAYS] or die 'fail on ALWAYS';
   $set[NEVER] and die 'fail on NEVER';
}
```

Is this better? What if we have so few elements that they can be mapped
onto the bits of an integer?

```perl
sub by_bits (@input) {
   my $set = 0;
   $set |= 0x01 << $_ for @input;
   $set & (1 << $input[rand @input]) or die 'fail in provided element';
   $set & (1 << ALWAYS) or die 'fail on ALWAYS';
   $set & (1 << NEVER) and die 'fail on NEVER';
}
```

[Benchmark][] time!

```
           Rate   Hash2    Hash Hash SA Hash ESA  Array    Bits Array SA Bits SA
Hash2     226/s      --     -2%    -13%     -14%   -58%    -66%     -69%    -77%
Hash      231/s      2%      --    -11%     -12%   -57%    -65%     -68%    -77%
Hash SA   260/s     15%     13%      --      -1%   -52%    -61%     -64%    -74%
Hash ESA  262/s     16%     13%      1%       --   -52%    -60%     -64%    -74%
Array     544/s    141%    135%    109%     108%     --    -18%     -25%    -46%
Bits      660/s    192%    185%    153%     152%    21%      --      -9%    -34%
Array SA  724/s    220%    213%    178%     176%    33%     10%       --    -28%
Bits SA  1004/s    344%    334%    285%     283%    85%     52%      39%      --
```

([Full script here][]).

All functions are called based on the same inputs, which are generated
automatically at the beginning and then reused over and over:

```perl
sub tests_iterator {
   state $vs = [ grep { $_ != NEVER } 0 .. 31 ];
   state $tests = [
      map {
         my $n = 3 + int(rand(27));
         [ shuffle(ALWAYS, map { $vs->[rand $vs->@*] } 0 .. $n) ];
      } 1 .. N_ARRANGEMENTS
   ];
   my $i = 0;
   return sub { return $i < N_ARRANGEMENTS ? $tests->[$i++]->@* : () };
}
```

`Hash`, `Hash2`, `Array`, and  `Bits` are the functions above, wrapped
into a driver function to call it multiple times with several inputs
(`$cb_name` is the name of one of the functions described above):

```perl
sub wrap ($cb_name) {
   my $cb = __PACKAGE__->can($cb_name);
   return sub {
      my $ti = tests_iterator();
      while (my @input = $ti->()) {
         eval {
            $cb->(@input);
            1;
         } or do {
            warn "$cb_name: $EVAL_ERROR";
         }
      }
      return;
   }
}
```

As all these calling of the callback introduce their own overhead, we
can also code *standalone* versions of those functions, just to see how
it goes (and results show that it goes definitely better).

These are all the `SA` versions. As an example, the bit-based
implementation and the winner in this round is the following:

```perl
sub by_bits_standalone {
   my $ti = tests_iterator();
   while (my @input = $ti->()) {
      my $set = 0;
      $set |= 0x01 << $_ for @input;
      $set & (1 << $input[rand @input]) or die 'fail in provided element';
      $set & (1 << ALWAYS) or die 'fail on ALWAYS';
      $set & (1 << NEVER) and die 'fail on NEVER';
   }
   return;
}
```

The `Hash ESA` is hash-based, with the explicit loop to avoid the
callign overhead, but using `exists` instead of the *value*.

I'm not too surprised of the results, except maybe that I didn't expect
such a good performance from arrays.

```
           Rate   Hash2    Hash Hash SA Hash ESA  Array    Bits Array SA Bits SA
Hash2     226/s      --     -2%    -13%     -14%   -58%    -66%     -69%    -77%
Hash      231/s      2%      --    -11%     -12%   -57%    -65%     -68%    -77%
Hash SA   260/s     15%     13%      --      -1%   -52%    -61%     -64%    -74%
Hash ESA  262/s     16%     13%      1%       --   -52%    -60%     -64%    -74%
Array     544/s    141%    135%    109%     108%     --    -18%     -25%    -46%
Bits      660/s    192%    185%    153%     152%    21%      --      -9%    -34%
Array SA  724/s    220%    213%    178%     176%    33%     10%       --    -28%
Bits SA  1004/s    344%    334%    285%     283%    85%     52%      39%      --
```

It's also interesting that the *standalone* versions underline the
differences in performance. This might be explained by the fact that
more efficient functions are called *more times*, so they suffer from
the performance hit more than their counterparts; when we remove this
overhead, there's more time to do more iterations on what we're
measuring.

I this this is everything for today, stay safe folks!


[Perl]: https://www.perl.org/
[Set]: https://en.wikipedia.org/wiki/Set_(abstract_data_type)
[Bencmark]: https://metacpan.org/pod/Benchmark
[Full script here]: {{ '/assets/code/sets-benchmark.pl' | prepend: site.baseurl }}
