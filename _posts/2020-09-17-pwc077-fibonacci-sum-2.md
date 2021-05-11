---
title: Fibonacci Sum part 2
type: post
tags: [ perl weekly challenge, maths, combinatorics ]
comment: true
date: 2020-09-17 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Let's complete the discussion about the [solution][Fibonacci Sum part
> 1] to the [Perl Weekly Challenge][] [#077][Challenge 077].

In [Fibonacci Sum part 1][] we laid the foundations for the solution to
the [Challenge 077][] with a function that gives us the [Zeckendorf's
decomposition][Zeckendorf's theorem] of a positive integer. It's now time
to address the other half of the problem, i.e. finding all possible
arrangements.

[Zeckendorf's decomposition][Zeckendorf's theorem] is minimal in the
sense that it provides the biggest (and fewest) Fibonacci numbers that
fit the request. Hence, every other solution can be built from it, by
trying to further decompose each of those Fibonacci numbers into
constituents, remembering that we cannot have duplicates in any of the
correct solutions.

Let's consider one of the examples, i.e. decomposing `9`. The minimal
*greedy* solution yields us with:

```
1 + 8 = 9
```

Now, `1` is the lowest of our Fibonacci Numbers and cannot be decomposed
further, so we can try with `8`:

```
1 + 3 + 5 = 9
```

Can we go further? Actually... no, because `3` cannot be decomposed (it
would yield a duplicate `1`) and `5` cannot be decomposed (it would
yield a duplicate `3`). So well... we're done.

What if we started at 22 instead?

```
1 + 21 = 22
1 + 8 + 13 = 22
1 + 3 + 5 + 13 = 22
```

Again... we're done. After struggling a bit, it's easy to see that
decomposing a Fibonacci number leads to a linear ladder of possibilities
and does not explode, because only the lowest constituent can be
decomposed (if any).

Too complicated? Let's look at `21` in our example; the immediate
decomposition is into its two predecessors:

```
8 + 13 = 21
```

It's easy to see that we cannot decompose `13` further, because it would
yield to a duplicate `8`. Maybe in some future round of
decomposition...? No again, because at that point the decompositions of
the `8` that we see here and the `8` needed for the `13` would compete
against each other and lead to a duplicate.

So, at any round, we're left with decomposing the lowest number in the
sequence, which simplifies things *a lot*:

```
3 + 5 + 13 = 21
1 + 2 + 5 + 13 = 21
```

and we're done.

Now, in the original decomposition of `22`, it's easy to see that the
last step is not useful, because we already have a `1`. This happense
any time we *hit* a lower number in [Zeckendorf's
decomposition][Zeckendorf's theorem] by decomposing a higher one:

```
8 + 34 = 42
8 + 13 + 21 = 42
```

We cannot go further with the `13` because it would need a duplicate
`8` *or* a duplicate `5` (constituent of the other `8`, so we're done.

With this in mind, here's how we will address the whole thing:

- compute the [Zeckendorf's decomposition][Zeckendorf's theorem] of the
  input number
- starting from the bigger constituent in the decomposition, compute all
  its alternative forms by breaking up its lowest constituent, up to the
  immediately following number in the decomposition of the original
  number
- try to mix and match all possible arrangements of alternatives for the
  Fibonacci numbers that make up the target integer.

Sounds complicated? It is!

Let's start simple. Say that we have number `44`, that is:

```
2 + 8 + 34 = 44
```

Now we find all possible alternative representations for these three
consitituents, cutting out branches that would yield a duplicate. We
start from `34` and break it up until we hit `8` (actually, we hit the
number *before* `8`)

```
34
21 + 13
```

We can do the same with the `8`, stopping at the `2` or the immediately
previous one:

```
8
3 + 5
```

The following function finds all possible alternatives for a Fibonacci
number, going down the ladder but only up to a certain point:

```perl
 1 sub alternatives {
 2    my ($i, $il) = @_;
 3    my @item = ($i);
 4    my @retval = ([$i]);
 5    while ($i > $il + 1) {
 6       pop @item;
 7       push @item, $i - 1, $i - 2;
 8       push @retval, [@item];
 9       $i -= 2;
10    }
11    return \@retval;
12 }
```

Again, we're working with indexes into an array of Fibonacci numbers,
but you get the idea. Starting from index `$i`, we go back and always
decompose (line 7) only the lowest constituent (line 6), until we hit a
rock bottom provided by a "lowest index" `$il` (line 5). This new
alternative is saved (line 8) and then we go back by two indexes (line
9) because we already used those Fibonacci numbers in line 7.

We're now ready to look at the `main` sub:

```perl
 1 sub main {
 2    my ($n) = @_;
 3 
 4    # compute the "basic" Zeckendorf decomposition of $n
 5    my $lk = lekkerkerker($n);
 6 
 7    # compute a "reasonable" decomposition into possible non-overlapping
 8    # components
 9    my @components;
10    for my $i (reverse 0 .. $#{$lk->{indexes}}) {
11       my $index = $lk->{indexes}[$i];
12       my $low_index = $i ? $lk->{indexes}[$i - 1] : 0;
13       my $alts = alternatives($index, $low_index);
14       push @components, $alts;
15    }
16 
17    # compute all possible arrangements, reject those with overlaps and
18    # print the others
19    nested_loops_recursive(
20       \@components,
21       sub {
22          my @lineup;
23          my %seen;
24          my $sum = 0;
25          for my $constituent (@_) {
26             for my $i (@$constituent) {
27                return if $seen{$i}++;
28                my $fi = $lk->{fibo}[$i];
29                push @lineup, $fi;
30                $sum += $fi;
31             }
32          }
33          die "sum mismatch ($sum vs $n)\n" unless $n == $sum;
34          my $lineup = join ' + ', sort {$a <=> $b} @lineup;
35          print {*STDOUT} "$lineup = $sum\n";
36       }
37    );
38 }
```

Line 5 calculates the [Zeckendorf's decomposition][Zeckendorf's
theorem], no big deal.

Lines 9 through 15 put in `@components` all possible representations of
each Fibonacci number in the decomposition, by calling `alternatives`
and providing the right extremes. Note that the lowest Fibonacci number
in the representation an go down to the bottom of the Fibonacci ladder,
so it gets a *lower index* of 0 (line 12).

At this point, we have that `@components` is an array of arrays of...
arrays, which we want to iterate over. Wait a minute... we can reuse
what we discussed in [A simplified recursive implementation of NestedLoops][]!

This happens in line 19 (note: we got rid of the `$opts` parameter): we
provide a reference to `@components` and a callback sub to analyze a
particular input arrangement (lines 21 to 36).

This sub is quite... boring: we make sure to avoid duplications (using
the `%seen` hash to bail out if some number appears twice, line 27),
record all constituents and make the sum again just to double check.

If we make it to line 34... yay, we have a good arrangement and we can
print it out as requested!

So... I guess it's all from me. If you want to take a look at the whole
solution, it's available [here][]. Have a good one!


[task #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-077/#TASK1
[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[Challenge 077]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-077/
[Zeckendorf's theorem]: https://en.wikipedia.org/wiki/Zeckendorf%27s_theorem
[Gerrit Lekkerkerker]: https://en.wikipedia.org/wiki/Gerrit_Lekkerkerker
[here]: https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-077/polettix/perl/ch-1.pl
[Fibonacci Sum part 1]: {{ '/2020/09/16/fibonacci-sum-1' | prepend: site.baseurl }}
[A simplified recursive implementation of NestedLoops]: {{ '2020/07/28/nested-loops-recursve' | prepend: site.baseurl }}
