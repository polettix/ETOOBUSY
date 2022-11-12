---
title: A Quiz from my past self
type: post
tags: [ maths, probabilities, coding, perl ]
comment: true
date: 2020-05-19 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Where I solve a mystery left by my past self.

As the rare readers of this blog of fixations know, I've been lately
interested into using the so-called *rejection method* to generate
random dice outcomes from other (hopefully) random dice outcomes. It all
started from [A 4-faces die from a 6-faces die][] and no, I still don't
regret this.

It turns out that I gave a non-trivial amount of thinking a few years
ago when I was *over-engineering* [Ordeal::Model][], a [Perl][] module
to shuffle things (that serves as the backend machinery for [ordeal][],
my take at generating a random bunch of picture to prompt story
creation.

# Over-engineering

As [Ordeal::Model][] main aim was to support [ordeal][], which is
admittedly an crystal case of *under-engineering* a UI, I think that the
[Fisher-Yates shuffle][] as it can be found in [List::Util::shuffle][]
was way, way totally good for the task.

Alas, I also like to learn a thing or two in these pet projects, so I
couldn't just take it and move on. To be fair, there was one key thought
that was bugging me a bit: is the shuffle biased in any sense?

I know that the [Fisher-Yates shuffle][] is unbiased *as a process*,
but it relies on a random source to generate integers within ranges and
*that* was something that was bugging me a bit. If the process is fed
with biased data, can we still say that the whole thing is unbiased?

I also didn't want to look into the actual implementation in
[List::Util][] - why do this when there was this beautiful wheel waiting
to be re-invented?


# Enter Ordeal::Model::ChaCha20

To make a long story short, I implemented [Ordeal::Model::ChaCha20][] to
provide an *as unbiased as I can possibly tell* source of randomness for
an implementation of randomly drawing stuff from a list.

Under the hood, it uses code taken from [Dana Jacobsen][]'s
[Math::Prime::Util::ChaCha][], adapted to work inside an object and used
to draw random bits and return them as a string of `0` and `1` by
calling the `_core` function:

```perl
 1 sub _bits_rand ($self, $n) {
 2    while (length($self->{_buffer}) < $n) {
 3       my $add_on = $self->_core((int($n / 8) + 64) >> 6);
 4       $self->{_buffer} .= unpack 'b*', $add_on;
 5    }
 6    return substr $self->{_buffer}, 0, $n, '';
 7 } ## end sub _bits_rand
 ```

## The main star

This source of random bits is then used by the very central function of
[Ordeal::Model::ChaCha20][], i.e. `int_rand ($low, $high)`, that takes a
range from where to draw random integers and gives you one... in that
range:

```perl
 1 sub int_rand ($self, $low, $high) {
 2    my $N = $high - $low + 1;
 3    my ($nbits, $reject_threshold) = $self->_int_rand_parameters($N);
 4    my $retval = $reject_threshold;
 5    while ($retval >= $reject_threshold) {
 6       my $bitsequence = $self->_bits_rand($nbits);
 7       $retval = 0;
 8       for my $v (reverse split //, pack 'b*', $bitsequence) {
 9          $retval <<= 8;
10          $retval += ord $v;
11       }
12    } ## end while ($retval >= $reject_threshold)
13    return $low + $retval % $N;
14 } ## end sub int_rand
```

Line 2 temporarily transforms the problem from *any integer within
`$low` and `$high`, included* to *any number between 0 included and `$N`
excluded*. This shift is reversed at the very end (line 13), so from now
on we concentrate on the simpler range.

Line 3 gets the relevant parameters for our rejection-based method. In
particular, `$nbits` represents how many random bits have to be drawn in
order to generate a candidate for the rejection method, and
`$reject_threshold` is an integer number from which the rejection will
start.

Loop in lines 5 to 12 apply the rejection method:

- get a sequence of `$nbits` bits (line 6)
- turn them into an unsigned integer (`$retval`, lines 7 to 11)
- apply the rejection method if this is too big (line 5).

## The puzzle wrapping

I promised a mystery, right? It's in the function that establishes the
*right* parameters `$nbits` and `$reject_threshold`, i.e. the following:

```perl
 1 sub _int_rand_parameters ($self, $N) {
 2    state $cache = {};
 3    return $cache->{$N}->@* if exists $cache->{$N};
 4 
 5    # basic parameters, find the minimum number of bits to cover $N
 6    my $nbits = int(log($N) / log(2));
 7    my $M = 2 ** $nbits;
 8    while ($M < $N) {
 9       $nbits++;
10       $M *= 2;
11    }
12    my $reject_threshold = $M - $M % $N; # same as $N here
13 
14    # if there is still space in the cache, this pair will be used many
15    # times, so we want to reduce the rejection rate
16    if (keys($cache->%*) <= CACHE_SIZE) {
17       while (($nbits * $M / $reject_threshold) > ($nbits + 1)) {
18          $nbits++;
19          $M *= 2;
20          $reject_threshold = $M - $M % $N;
21       }
22    }
23    return ($nbits, $reject_threshold);
24 }
```

I keep a cache (line 2) that is a sort of a global variable; this is OK
because the function actually only depends on `$N`, not on the specific
object that calls it. For paranoid reasons this cache is limited in size
(test in line 16) but this is a detail.

If we have the item in the cache then we're done: just return the two
numbers for `$nbits` and `$reject_threshold`.

Otherwise, we first calculate `$nbits` in a *reasonable* way: let's find
the closer power of 2 that is greater than, or equal to, the input
number `$N`. Line 6 will calculate the number of bits for the power of 2
that is smaller than, or equal to, `$N`, so we do some adjustment in
lines 8 to 11 to make sure that our power of 2 is greater than, or equal
to, our target `$N`.

You might object that line 8 might be a `if` just as well. But I'm
paranoid, so the `while` works fine here to protect my sleep from weird
stuff in the floating point operation in line 6. I know, I know.

Now that we have `$M`, our power of 2, we can also calculate the
threshold for the rejection (line 12). If you look hard into it, it
might be also expressed as:

```perl
my $reject_threshold = $N;
```

but we'll keep it as-is to make it the same as line 20 and be consistent
in our way to calculate the threshold.

So far nothing misterious, but then we ask ourselves if we're going to
cache this value. This got me cursing back at the past me for *not*
writing a comment about what I had in mind!

As anticipated above, we save the pair of values we found only if there
is still space in the cache; in this case, it makes sense to save an
optimized value that will be reused over and over. Hopefully.

How do we optimize `$nbits` and `$reject_threshold` though?

## The puzzle

The values of `$nbits`, `$M` and `$reject_threshold` are the *lowest
possible* ones that allow us to apply the rejection method. Higher
values, though, would work fine as well: at the expense of getting more
bits (i.e. higher values for `$nbits`) we draw numbers from a greater
pool, but the amount of rejections is strictly capped so the probability
of rejection generally decreases.

How can we cap the rejection? Let's make an example and aim to generate
integers below 5 (i.e. `$N` is 5):

- the minimum number for `$nbits` is 3, which gives us `$M` equal to 8.
  Less bits would give us up to 4 which isn't sufficient to generate
  what we are after.
- with the minimum number of bits, we get a failure 3 times out of 8
  (i.e. `5`, `6`, and `7`)
- with one more bit we draw number from a pool of 16 candidates, so it
  *might* seem that we are rejecting more. On the other hand, we can do
  the following mapping and only miss one value (`15`):
  - `0`, `5`, and `10` map onto `0`
  - `1`, `6`, and `11` map onto `1`
  - ...
  - `4`, `9`, and `14` map onto `4`

So, when we consider all *whole* blocks of `$N` items, we restrict the
rejection only to the the final block, which by definition has a size
that is strictly less than `$N`.

Hence, the number of rejected candidates is always strictly less than
`$N`, but the probability of a rejection decreases as we add more bits
because the rejected candidates get divided by `$M`.

So... adding bits decreases a probability of rejection. But where should
we stop? Should we add one more bit or be done with the value we have?

The code does the optimization in this cycle, with the condition in line
17:

```perl
17       while (($nbits * $M / $reject_threshold) > ($nbits + 1)) {
18          $nbits++;
19          $M *= 2;
20          $reject_threshold = $M - $M % $N;
21       }
```

which has been a mistery for me when I re-read it after about two years.

And then... it came to me again! I almost certainly reasoned how
follows.

What is the expected number of draws that I will have to perform with
`$nbits`? All draws are assumed to be independent from one another, so
it's a geometric distribution where the probability of the event we're
interested into is:

$$ P_{accept} = \frac{R_t}{M} = \frac{R_t}{2^k} $$

where $R_t$ is the `$reject_threshold` and $k$ is `$nbits`. In a
geometric distribution, the expected value for the number of draws until
we have a success is the inverse of this probability. Hence, if we draw
$k$ bits at every attempt, how many bits are we expecting to use for
each non-rejected value? We just have to multiply by $k$ and we will get
$K$:

$$ K = \frac{k}{P_{accept}} = k \cdot \frac{2^k}{R_t}$$

which is *exactly* the left hand side in the test of line 17.

At this point we can as ourselves: does it make sense to draw one more
bit instead? Well, if the value $K$ is greater than $k+1$, then we can
leverage the *go to next power of 2* trick to reduce the probability of
a rejection and hopefully get a better result. On the other hand, if the
average number of bits for each successful (i.e. non-rejected) draw is
less than that, or even equal to it, we don't get an advantage (in
average) so we can just stop expanding.

In our example where `$N` is 5, the probability of an accepted value is
$\frac{5}{8}$, which means that we will have to do $\frac{8}{5} = 1.6$
draws for each successful (i.e. non-rejected) value. This means that, on
average, we will *spend* $3 \cdot 1.6 = 4.8$ bits per number. Why not
draw 4 bits then? On average we will *in any case* draw more!

In this case, with 4 bits we would have an acceptance probability of
$\frac{15}{16}$ (remember that we can use all outcomes from `0` up to
`14` included, and only reject `15`), which means an average number of
rolls equal to $\frac{16}{15} \approx 1.07$ and an average number of
bits equal to $4 \cdot \frac{16}{15} \approx 4.27$, which is only
slightly over 4 bits and in any case better than the 4.8 that we would
get with 3 bits only.

Now, the 4.27 we got is *not* greater than 5, so getting 5 bits instead
of 4 would not be advantageous in average, but only make us waste bits.

In conclusion, there we have our condition for taking the next bit:

$$k \cdot \frac{2^k}{R_t} > k + 1$$

i.e. the condition in line 17. Mystery solved!

# My take away...

... is to document all these things in the future, at least put a hint
of where the solution lies, so that I will have the mystery *and* the
solution!!!

[A 4-faces die from a 6-faces die]: {{ '2020/05/11/d6-to-d4' | prepend: site.baseurl }}
[Ordeal::Model]: https://metacpan.org/pod/Ordeal::Model
[Perl]: https://www.perl.org/
[ordeal]: https://ordeal.introm.it/
[Fisher-Yates shuffle]: https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
[List::Util::shuffle]: https://metacpan.org/pod/List::Util#shuffle
[List::Util]: https://metacpan.org/pod/List::Util
[Ordeal::Model::ChaCha20]: https://metacpan.org/pod/Ordeal::Model::ChaCha20
[Dana Jacobsen]: https://metacpan.org/author/DANAJ
[Math::Prime::Util::ChaCha]: https://metacpan.org/pod/Math::Prime::Util::ChaCha
