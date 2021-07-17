---
title: More commenting... maybe?
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-07-18 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> My code might use some more commenting, maybe?

[The Weekly Challenge][] is an interesting activity that proves
invaluable from many points of view.

From a very practical point of view, it gave me the possibility to cover
*at least* two days per week in my personal challenge to write one post
per day for at least one year. That's almost 29% of the topics!

Then there's the feedback.

Which comes in multiple forms: [Mohammad][]'s terse synthesis in the
[Perl Weekly][] newsletter, a few sparse comments every now and then
from the casual readers, and the in-depth (while still light) commentary
from Colin Crain in his [Perl Solutions Review][].

One trend that I noted is that the code I write tends (sometimes?) to be
*cryptic*. As an example, here's Colin's commentary about [PWC118 -
Binary Palindrome][] (emphasis mine):

> Flavio here demonstrates the use of bitwise operations to examine the
> underlying binary directly, without the need to convert any formats.
> **This is of course both extremely clever and intensely opaque at the
> same time, and kind of makes my brain hurt**. You know, just a little.

This is surely something to think upon, so I went back to both the code
*and* the blog post to try and see it with a different eye (after a
couple of week, for me it's like someone else wrote it).

And right Colin is, as there are *at least* two defects in this code:

- it's *clever* (maybe not really *extremely*), which is a red flag
  because it will later require a higher amount of brain energy to read
  and understand again;
- it's *intensely opaque* because it's both very compact and the mere
  implementation of an algorithm that was born and remained entirely in
  my brain. (This time I think that the adjective *intensely* applies).

One observation is that my code errs to the [write-only][] side. I mean,
the same code might have been written like this:

```perl
sub binary_palindrome ($N) {
   die "invalid $N (positive integers are OK)\n"
      if $N !~ m{\A [1-9]\d* \z}mxs;
   return unless $N % 2;
   my $M = 0;
   my $n = $N;
   while ($n > 0) {
      $M = ($M << 1) | ($n & 1);
      $n >>= 1;
   }
   return $M == $N;
}
```

Now the code is less *compact*, which also makes it more readable
(hopefully). This also eases addressing a second possible observation,
that is *a few comments on the intent would help a lot*:

```perl
sub binary_palindrome ($N) {
   die "invalid $N (positive integers are OK)\n"
      if $N !~ m{\A [1-9]\d* \z}mxs;
   return unless $N % 2;
   my $M = 0;  # this will keep the "inverted" $N
   my $n = $N; # this will ease doing the inversion
   while ($n > 0) { # go until there are bits set to "1"
      $M = ($M << 1) | ($n & 1); # "push" a bit from $n to $M
      $n >>= 1;                  # "pop" same bit from $n
   }
   # Now $M is the "inverted" version of $N. Testing for palindrome
   # means that $M is equal to $N.
   return $M == $N;
}
```

This is better, but still does not shed a light on the algorithm I use,
so a few additional comments on this can help.

This, in turn, creates a problem regarding the *intended audience*. I
will assume *people that know what a stack is and how it is
manipulated*, because the people who are likely to actually read my code
are almost surely programmers and know the language associated to
stacks. Besides this, any further explanation would probably *not*
belong to comments anyway.

```perl
sub binary_palindrome ($N) {
   die "invalid $N (positive integers are OK)\n"
      if $N !~ m{\A [1-9]\d* \z}mxs;
   return unless $N % 2;

   # Now we create an "inverted" version of $N into $M. We do this by
   # treating both of them as stacks, where we "pop" items from $N and
   # "push" them into "$M". As we need $N at the end, we first copy $N
   # into a temporary copy $n, and do the "stack operations" on $n
   # instead.
   # Operations on these stacks are implemented using bit-wise operations:
   # - the "top" operation to get the top of stack $n is done by
   #   "masking" it with value 1, i.e. ($n & 1)
   # - the "push" involves two sub-steps:
   #   - making space for the new bit in the least-significant position
   #     in $M, i.e. shifting all bits in $M to the left with ($M << 1)
   #   - setting the newly created position/bit in $M using a bitwise OR
   #     operation |
   # - the "pop" is the inverse of the "push", so it's again a shift
   #   operation but done to the right.
   my $M = 0;  # "stack" to keep the "inverted" $N
   my $n = $N; # "stack" to do the actual inversion
   while ($n > 0) { # go until there are non-zero items in "stack" $n
      $M =           # "push" $M with "top" from $n
         ($M << 1)   # make space for the new item in the stack
         | ($n & 1); # set newly created position with "top" from $n
      $n >>= 1;      # "pop" $n
   }
   # Now $M is the "inverted" version of $N. Testing for palindrome
   # means that $M is equal to $N.
   return $M == $N;
}
```

One last bit is in the initial `return unless...`, which seems a bit
gratuitous/clever/opaque:

```perl
sub binary_palindrome ($N) {
   die "invalid $N (positive integers are OK)\n"
      if $N !~ m{\A [1-9]\d* \z}mxs;

   # Leading zeroes are *always* ignored, so there is no possible
   # palindrome that can have trailing zeroes. This means that the input
   # integer $N has the least significant bit set to 1, i.e. it is not
   # divisible by 2. If it is, we can return immediately with a "False".
   return unless $N % 2;
   ...
```

Now, as I'm writing this, I notice that using bitwise operations all
over the place *except* this initial test is not going to win any prize
in *consistency*, so it's better to use a bitwise operation also for
this initial test.

All in all, the final version is the following:

```perl
sub binary_palindrome ($N) {
   die "invalid $N (positive integers are OK)\n"
      if $N !~ m{\A [1-9]\d* \z}mxs;

   # Leading zeroes are *always* ignored, so there is no possible
   # palindrome that can have trailing zeroes. This means that the input
   # integer $N has the least significant bit set to 1, or we can
   # immediately return with a "false" answer.
   return unless $N & 1;

   # Now we create an "inverted" version of $N into $M. We do this by
   # treating both of them as stacks, where we "pop" items from $N and
   # "push" them into "$M". As we need $N at the end, we first copy $N
   # into a temporary copy $n, and do the "stack operations" on $n
   # instead.
   # Operations on these stacks are implemented using bit-wise operations:
   # - the "top" operation to get the top of stack $n is done by
   #   "masking" it with value 1, i.e. ($n & 1)
   # - the "push" involves two sub-steps:
   #   - making space for the new bit in the least-significant position
   #     in $M, i.e. shifting all bits in $M to the left with ($M << 1)
   #   - setting the newly created position/bit in $M using a bitwise OR
   #     operation |
   # - the "pop" is the inverse of the "push", so it's again a shift
   #   operation but done to the right.
   my $M = 0;  # "stack" to keep the "inverted" $N
   my $n = $N; # "stack" to do the actual inversion
   while ($n > 0) { # go until there are non-zero items in "stack" $n
      $M =           # "push" $M with "top" from $n
         ($M << 1)   # make space for the new item in the stack
         | ($n & 1); # set newly created position with "top" from $n
      $n >>= 1;                  # "pop" $n
   }
   # Now $M is the "inverted" version of $N. Testing for palindrome
   # means that $M is equal to $N.
   return $M == $N;
}
```

This is a much different function now! Maybe it can still give a bit of
headache... but hopefully much less than before 🙄


[The Weekly Challenge]: https://theweeklychallenge.org/
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[p5-reviews]: https://theweeklychallenge.org/p5-reviews/
[Mohammad]: http://www.manwar.org/
[Perl Weekly]: https://perlweekly.com/
[Perl Solutions Review]: https://theweeklychallenge.org/p5-reviews/
[PWC118 - Binary Palindrome]: {{ '/2021/06/23/pwc118-binary-palindrome/' | prepend: site.baseurl }}
[write-only]: https://www.techopedia.com/definition/24383/write-only-code
