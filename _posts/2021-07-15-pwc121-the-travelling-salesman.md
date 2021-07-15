---
title: PWC121 - The Travelling Salesman
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-07-15 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#121][].
> Enjoy!

# The challenge

> You are given a NxN matrix containing the distances between N cities.
>
> Write a script to find a round trip of minimum length visiting all N
> cities exactly once and returning to the start.
>
> **Example**
>
>     Matrix: [0, 5, 2, 7]
>             [5, 0, 5, 3]
>             [3, 1, 0, 6]
>             [4, 5, 4, 0]
>     
>     Output:
>             length = 10
>             tour = (0 2 1 3 0)
>
>> BONUS 1: For a given number N, create a random NxN distance matrix
>> and find a solution for this matrix.
>
>> BONUS 2: Find a solution for a random matrix of size 15x15 or 20x20


# The questions

As it often happens, some questions are more... *assumptions*.

As we're talking about distances between cities, the assumption is that
they are greater than zero.

The NxN matrix needs not be symmetric, as also the example shows. This
is consistent with one-way routes.

It's a bit more difficult to understand whether the NxN matrix respects
some *triangular constraint*. I mean, we are assuming that each city is
*directly* connected to any other city, and also that this connection
might be *worse* than passing through other cities. This is not an issue
with the main problem, more for the bonus of generating a random
arrangement.

Last, regarding the second bonus... is it 15x15 or 20x20?!?


# The solution

The first solution, that is still good for low values of $N$ (say up to
10 or so) is to just *brute force* the problem. With N cities, we fix
one of them (let's call it $0$) and generate all possible permutations
of the other ones (let's call them with integers from $1$ up to $N -
1$). This gives us all possible paths by starting from $0$, going
through the permutation, and going back to $0$.

Here's the example in [Raku][]:

```raku
sub tsp-bf ($dist-from-to) {
   my $n = $dist-from-to.elems;
   my ($best-distance, $best-path);
   for permutations(1 .. $n - 1) -> $perm {
      my $from = 0;
      my $sum = 0;
      for |$perm, 0 -> $to {
         $sum += $dist-from-to[$from][$to];
         $from = $to;
      }
      ($best-distance, $best-path) = ($sum, $perm)
         if ! defined($best-distance) || $sum < $best-distance;
   }
   return ($best-distance, (0, |$best-path, 0));
}
```

The `$dist-from-to` is assumed to be a bi-dimensional array whose first
level contains each row of the input matrix. The [permutations][]
built-in comes handy here, allowing us to concentrate on the problem.

This is easily translated in [Perl][], leveraging our old friend
[Iterator-based implementation of Permutations][]:

```perl
sub tsp_bf ($dist_from_to) {
   my $n = $dist_from_to->@*;
   my ($best_distance, $best_path);
   my $pit = permutations_iterator(items => [1 .. $n - 1]);
   while (my @perm = $pit->()) {
      my ($from, $sum) = (0, 0);
      for my $to (@perm, 0) {
         $sum += $dist_from_to->[$from][$to];
         $from = $to;
      }
      ($best_distance, $best_path) = ($sum, [@perm])
        if !defined($best_distance) || $sum < $best_distance;
   } ## end while (my @perm = $pit->(...))
   return ($best_distance, [0, $best_path->@*, 0]);
} ## end sub tsp_bf ($dist_from_to)
```

To address the first bonus, we just generate a random matrix with all
positive values, except on the diagonal (the distance of a city from
itself is 0). For simplicity we're restricting to integers here, but
it's not a constraint.

```perl
sub generate_randoms ($n) {
   my @retval;
   for my $i (0 .. $n - 1) {
      my @row = map { 1 + int(rand 13) } 1 .. $n;
      $row[$i] = 0;
      push @retval, \@row;
   }
   return \@retval;
}
```

The underlying model is a bit... crude, maybe it would be better to just
put points on a rectangle and calculate their mutual distances. Anyway,
as an input for the problem it should be fine.

To address the other bonus, a different algorithm is needed. I took a
look at the [Wikipedia page on the Travelling salesman problem][] and it
does not give too much... except that *branch and bound* solutions
should be better.

Anyway, in this case I settled for the [Held–Karp algorithm][] because:

- it has a much better complexity than brute-force
- we're limited to 20x20 anyway, so we don't need anything *too
  aggresive*.

The page on the algorithm is a bit confusing, because:

- it has a good textual explanation of the algorithm;
- it has an example that is more or less in line with the explanation;
- it has some pseudocode that I can't relate 1-to-1 with the two above.

For this reason, I changed it to be in line with the explanation and the
example, resulting in this:

```
function algorithm TSP (G, n) is
    for e := 2 to n do
        g({}, e) := d(1, e)
    end for

    for s := 2 to n−1 do
        for all S ⊆ {2, . . . , n}, |S| = s do
            for all e ∈ S do
               g(S\{e}, e) := min_{m ∈ S\{e}} [g(S\{m, e}, m) + d(m, e)]
               # & keep best predecessor (yielding the minimum)
            end for
        end for
    end for

    opt := min_{k = 2 to n} [g({2, 3, ..., n}\{k}, k) + d(k, 1)]
    return opt
end function
```

I will not put the implementations in [Raku][] and [Perl][] here,
because they're a bit long and are more or less an implementation of the
algorithm above (with the small addition that allows to get the optimal
path out of the calculation). They are available in the [Perl Weekly
Challenge][] repository, [here][pl] and [here][raku].

The [Perl][] implementation is a bit *lower level*, using only arrays,
while the [Raku][] implementation uses sets etc. I'm not sure, though,
this is an advantage, at least computationally-wise, because the
[Perl][] solution is way faster.

Both solutions have an exponential behaviour where adding one city more
or less means a factor of about $2.4$ on the time required to calculate
it all. The 20x20 example case is solved by [Perl][] in about 2 and a
half minutes, while an extrapolation for [Raku][] would require a
handful of hours. I think that the [Raku][] implementation can be
[Raku][]-ized much more, though, yielding an easily parallelizable
algorithm that might take advantage of multiple cores to speed up the
execution.

As hinted by the Wikipedia page, the memory requirements can be a bit
taxing as the number of cities grows. I think it should be possible to
remove *lower level* values of hash `%g` as we move up the ladder,
although the `%p` hash tracking the predecessor still has to be kept
until the end of the computation.

All in all it's been... very interesting!


[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#121]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-121/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-121/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Iterator-based implementation of Permutations]: {{ '/2021/01/30/permutations-iterator/' | prepend: site.baseurl }}
[Wikipedia page on the Travelling salesman problem]: https://en.wikipedia.org/wiki/Travelling_salesman_problem
[Held–Karp algorithm]: https://en.wikipedia.org/wiki/Held%E2%80%93Karp_algorithm
[permutations]: https://docs.raku.org/routine/permutations
[combinations]: https://docs.raku.org/routine/combinations
[pl]: https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-121/polettix/perl/ch-2.pl
[raku]: https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-121/polettix/raku/ch-2.raku
