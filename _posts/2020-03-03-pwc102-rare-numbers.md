---
title: PWC102 - Rare Numbers
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-03-03 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#102][]. Enjoy!

# The challenge

> You are given a positive integer `$N`. Write a script to generate all
> Rare numbers of size `$N` if exists. Please checkout the [page][] for
> more information about it.

# The questions

One first question that came to mind is *what if there is no rare number
of size `$N`?*. I guess it's fair at this point to print out an empty
list.

Also, one question would be how concerned should we be for the carbon
footprint required by our search. I mean, computation might get *heavy*
and we all care for our plante, don't we?

(Well, probably the answer to the last question is not such a
no-brainer, but let's not get political).

Anyway, I decided that too much is too much, so I'll throw an exception
if the input `$N` is too high.


# The solution

You really have to blame `Colin Crain` for this solution, because I like
his (*her? their?* - here I get political again!) reviews of solutions a
lot, and they surely inspire me to *try* and get more creative.

So, this time I thought it better to *not* solve the problem. Well, not
to solve it with an algorithm, but more like a human.

With my abundant amount of lazyness, what would I do? I'd click on the
[page][], eventually land on the [other page][] and just read. Why not
transfer this bit of lazyness to a little AI that will conquer the world
one day?

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

use FindBin '$Bin';
use lib "$Bin/../local/lib/perl5";
use Mojo::UserAgent;

my $digits = shift || 10;
my $rn = rare_numbers($digits);

my $title = ($digits == 1) ? '1 digit:' : "$digits digits:";
say $title, ' ', join ', ', $rn->@*;

sub rare_numbers ($N) {
   my ($ml, $retval) = get_rare_numbers_for($N, get_rn_cache());
   return $retval if $N <= $ml;
   ($ml, $retval) = get_rare_numbers_for($N, get_rn_web());
   return $retval if $N <= $ml;
   die "carbon footprint too high, sorry!\n";
}

sub get_rare_numbers_for ($N, $list) {
   my @retval;
   my $max_length = 0;
   for my $item ($list->@*) {
      my $len = length $item;
      $max_length = $len if $len > $max_length;
      last if $max_length > $N;
      push @retval, $item if $len == $N;
   }
   return ($max_length, \@retval);
}

sub get_rn_web {
   my $ua = Mojo::UserAgent->new(connect_timeout => 5, max_redirects => 5);
   my $res = $ua->get('http://oeis.org/A035519/b035519.txt')->res;
   die "web is not collaborating, sorry!\n" unless $res->is_success;
   return [
      map { my ($i, $n) = split m{\s+}; $n } split m{\n}mxs, $res->body
   ];
}

sub get_rn_cache { [ 65, 621770, 281089082, 2022652202, 2042832002 ] }
```

The solution is two-fold:

- we keep a little cache just for the easy cases. With this cache alone,
  we can address the example use cases without hitting the web... less
  carbon footprint, yay!
- as a fallback, we go to the web and look for the current list using
  [Mojo::UserAgent][]. Remember [Mojo::UserAgent introductory notes][]?

The search itself is easy: just look for all items whose length is the
same as `$N` and we're done.

The output from the web page is a simple text like this:

```
1 65
2 621770
3 281089082
4 2022652202
5 2042832002
...
```

For this reason, we `split` each line by spaces, then take the second
item that is our rare number.

If the solution cannot be found... an exception will be thrown, so then
go look for the solution elsewhere!

So long for now... have a good one and stay safe!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#102]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-102/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-102/#TASK1
[Perl]: https://www.perl.org/
[page]: http://www.shyamsundergupta.com/rare.htm
[other page]: http://oeis.org/A035519/b035519.txt
[Mojo::UserAgent introductory notes]: {{ '/2021/02/22/mojo-useragent-intro-notes/' | prepend: site.baseurl }}
[Mojo::UserAgent]: https://metacpan.org/pod/Mojo::UserAgent
