---
title: PWC236 - Exact Change
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-09-29 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#236][]. Enjoy!

# The challenge

> You are asked to sell juice each costs $5. You are given an array of
> bills. You can only sell ONE juice to each customer but make sure you
> return exact change back. You only have $5, $10 and $20 notes. You do
> not have any change in hand at first.
>
> Write a script to find out if it is possible to sell to each customers
> with correct change.
>
> **Example 1**
>
>     Input: @bills = (5, 5, 5, 10, 20)
>     Output: true
>
>     From the first 3 customers, we collect three $5 bills in order.
>     From the fourth customer, we collect a $10 bill and give back a $5.
>     From the fifth customer, we give a $10 bill and a $5 bill.
>     Since all customers got correct change, we output true.
>
> **Example 2**
>
>     Input: @bills = (5, 5, 10, 10, 20)
>     Output: false
>
>     From the first two customers in order, we collect two $5 bills.
>     For the next two customers in order, we collect a $10 bill and give back a $5 bill.
>     For the last customer, we can not give the change of $15 back because we only have two $10 bills.
>     Since not every customer received the correct change, the answer is false.
>
> **Example 3**
>
>     Input: @bills = (5, 5, 5, 20)
>     Output: true

# The questions

Long time no see, uh?!?

One question is about this shortage of juice... why only one per
customer?

More seriously, it seems that we're not allowed to sort the incoming
bills by value, otherwise the consideration *You do not have any change
in hand at first.* would not be needed. So I'm assuming that they have
to be addressed as a FIFO.

# The solution

In the good ol' times spirit, let's start with [Raku][] first:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@bills) { put exact-change(@bills) ?? 'true' !! 'false' }

sub exact-change (@bills) {
   my %bills-of = <5 0 10 0 20 0>;
   for @bills -> $bill {
      if $bill == 5 { %bills-of<5>++ }
      elsif $bill == 10 {
         return False unless %bills-of<5>-- > 0;
         %bills-of<10>++;
      }
      else { # $bill == 20
         return False unless %bills-of<5>-- > 0;
         if %bills-of<10> >= 1 {
            %bills-of<10>--;
         }
         elsif %bills-of<5> >= 2 {
            %bills-of<5> -= 2;
         }
         else {
            return False;
         }
      }
   }
   return True;
}
```

Every customer with a 5$ bill is very welcome and we have to give no
change back. Every customer with a 10$ bill gets back a 5$ bill if
available, otherwise we bail out. Customers with 20$ bills always get
one 5$ bill back, then a 10$ bill (if possible) or two 5$ bills. It's
always better to check if 10$ bills are available first, because the 5$
bills are the most needed in changes.

[Perl][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

say exact_change(@ARGV) ? 'true' : 'false';

sub exact_change (@bills) {
   my %bills_of = map { $_ => 0 } (5, 10, 20);
   for my $bill (@bills) {
      if ($bill == 5) {
         $bills_of{5}++;
      }
      elsif ($bill == 10) {
         return 0 unless $bills_of{5}-- > 0;
         $bills_of{10}++;
      }
      else { # $bill == 20
         return 0 unless $bills_of{5}-- > 0;
         if ($bills_of{10} >= 1) {
            $bills_of{10}--;
         }
         elsif ($bills_of{5} >= 2) {
            $bills_of{5} -= 2;
         }
         else {
            return 0;
         }
      }
   }
   return 1;
}
```

I think this is it!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#236]: https://theweeklychallenge.org/blog/perl-weekly-challenge-236/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-236/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
