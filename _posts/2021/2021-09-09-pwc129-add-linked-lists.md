---
title: PWC129 - Add Linked Lists
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-09-09 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#129][].
> Enjoy!

# The challenge

Note: I'm removing the hints on how to operate inside the examples.

> You are given two linked list having single digit positive numbers.
>
> Write a script to add the two linked list and create a new linked
> representing the sum of the two linked list numbers. The two linked
> lists may or may not have the same number of elements.
>
>> HINT: Just a suggestion, feel free to come up with your own unique
>> way to deal with the task. I am expecting a class representing linked
>> list. It should have methods to create a linked list given list of
>> single digit positive numbers and a method to add new member. Also
>> have a method that takes 2 linked list objects and returns a new
>> linked list. Finally a method to print the linked list object in a
>> user friendly format.
>
> **Example 1:**
>
>     Input: L1 = 1 -> 2 -> 3
>            L2 = 3 -> 2 -> 1
>     Output: 4 -> 4 -> 4
>
> **Example 2:**
>
>     Input: L1 = 1 -> 2 -> 3 -> 4 -> 5
>            L2 =           6 -> 5 -> 5
>     Output:     1 -> 3 -> 0 -> 0 -> 0

# The questions

I wonder if my continuous nit-picking and writing questions on these
challenges played a part in this one particularly, because [manwar][] is
being *extremely* detailed - to the point that there are some
*expectations* on the implementation. I hope I didn't too much upsetting
😅

On a more serious business note, I'd ask if *double-linked* lists would
qualify for this challenge. As some operations go in one directions,
while others go the other one, it would be handy to use them. Anyway
we'll assume a *strict* interpretation here, and rely on *single-linked*
lists.

Then I'll make the assumption that the inputs might also contain `0` in
addition to *positive* single-digit numbers. This I think was some kind
of typo, although strictly speaking I'll just avoid doing the input
checking for this one, so it technically works for strictly adherent
linked lists.

Last, a question for the reader: please pay your homage to [manwar][],
the challenge could have easily required operators overloading. Which
I'll assume, anyway 😎

# The solution

This challenge really struck a cord. Linked lists throw me back to my
first course in Computer Science back to around 1992, which is *almost
30 years ago*. It's as if someone in 1992 were talking to me about
something happening in 1963. Wow.

Having gone back that much in time, the execution is... adherent to
[manwar][]'s wishes and requirements, with really little added.

In true "being fair" with may favourite languages, [Perl][] goes first
in this case.

## Perl

So... object orientation. In [Perl][]. If it only there were something
cool in CORE... well, while we wait for it (*I so want it*) let's stick
with the *minimialistic* approach that **is** in core.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use Test::More;
use List::Util 'max';

for my $test (
   [
      '1 -> 2 -> 3',
      '3 -> 2 -> 1',
      '4 -> 4 -> 4',
   ],
   [
      '1 -> 2 -> 3 -> 4 -> 5',
      '6 -> 5 -> 5',
      '1 -> 3 -> 0 -> 0 -> 0',
   ],
   [
      '9 -> 8 -> 7',
      '1 -> 3',
      '1 -> 0 -> 0 -> 0',
   ],
) {
   my ($tl1, $tl2, $texp) = $test->@*;
   my $len = max map { length $_ } $test->@*;
   my $l1 = LinkedList->create(split m{\s*->\s*}mxs, $tl1);
   is $l1->stringify, $tl1, sprintf "  (%${len}s)", $tl1;
   my $l2 = LinkedList->create(split m{\s*->\s*}mxs, $tl2);
   is $l2->stringify, $tl2, sprintf "+ (%${len}s)", $tl2;
   my $sum = $l1 + $l2;
   is $sum->stringify, $texp, sprintf "= (%${len}s)", $texp;
}

done_testing();

package LinkedListItem;
use experimental 'signatures';
no warnings 'experimental::signatures';
sub label ($s, @n) { $s->{label} = $n[0] if @n > 0; $s->{label} }
sub new ($p, %s) { bless \%s, $p }
sub succ ($s, @n) { $s->{succ} = $n[0] if @n > 0; $s->{succ} }

package LinkedList;
use experimental 'signatures';
no warnings 'experimental::signatures';
use overload '+' => \&add;
sub create ($p, @labels) {
   my $l = $p->new;
   $l->insert($_) for CORE::reverse(@labels);
   return $l;
}
sub for_each ($self, $cb) {
   my $p = $self->{head};
   while (defined $p) {
      $cb->(local $_ = $p->label);
      $p = $p->succ;
   }
   return $self;
}
sub insert ($self, $l) {
   $self->{head} = LinkedListItem->new(label => $l, succ => $self->{head});
   return $self;
}
sub new ($p, %s) { bless {head => undef, %s}, $p }
sub stringify ($s) {
   my @labels;
   $s->for_each(sub {push @labels, $_});
   return join ' -> ', @labels;
}
sub reverse ($self) {
   my $r = LinkedList->new;
   $self->for_each(sub {$r->insert($_)});
   return $r;
}
sub add ($s, $t, @ignore) {
   my $ps = $s->reverse->{head};
   my $pt = $t->reverse->{head};
   my $r = LinkedList->new;
   my $carry = 0;
   while (defined($ps) || defined($pt) || $carry) {
      my ($vs, $vt) = map {
         (my $v, $_) = $_ ? ($_->label, $_->succ) : (0, undef);
         $v;
      } ($ps, $pt);
      my $v = $vs + $vt + $carry;
      ($v, $carry) = $v > 9 ? ($v - 10, 1) : ($v, 0);
      $r->insert($v);
   }
   return $r;
}
```

As anticipated, a pretty much boring implementation. It's probably worth
noting that operator `+` is overloaded to call the `add` method. This
explaines why the method itself contains a *catchall* parameter
`@ignore`: the overloading passes one more parameter!

## Raku

[Raku][] implementation is a bit cleaner and declarative, but otherwise
it's a direct translation. I feel like I really missed more idiomatic
ways of expressing these classes.

```raku
#!/usr/bin/env raku
use v6;
use Test;

class LinkedList {
   my class LinkedListItem {
      has $.label is required;
      has $.succ is rw = Nil;
   }

   has $.head is rw = Nil;

   method create (::?CLASS:U $class: *@labels) {
      my $l = $class.new;
      @labels.reverse.map: {$l.insert($^label)};
      return $l;
   }

   method for-each (&cb) {
      my $p = self.head;
      while $p {
         &cb($p.label);
         $p = $p.succ;
      }
      return self;
   }

   method insert ($l) {
      self.head = LinkedListItem.new(label => $l, succ => self.head);
   }

   method Str () {
      my @labels;
      self.for-each({@labels.push: $^label});
      return @labels.join(' -> ');
   }

   method reverse () {
      my $r = LinkedList.new;
      self.for-each({$r.insert($^label)});
      return $r;
   }

   method add ($t) {
      my $ps = self.reverse.head;
      my $pt = $t.reverse.head;
      my $r = LinkedList.new;
      my $carry = 0;
      while defined($ps) || defined($pt) || $carry {
         my ($vs, $vt) = ($ps, $pt).map: -> $n is rw {
            (my $v, $n) = $n ?? ($n.label, $n.succ) !! (0, Nil);
            $v;
         }; # dirty dirty dirty
         my $v = $vs + $vt + $carry;
         ($v, $carry) = $v > 9 ?? ($v - 10, 1) !! ($v, 0);
         $r.insert($v);
      }
      return $r;
   }
}

multi sub infix:<+> (LinkedList:D $s, LinkedList:D $t) { $s.add($t) }

sub MAIN () {
   my @tests =
      [
         '1 -> 2 -> 3',
         '3 -> 2 -> 1',
         '4 -> 4 -> 4',
      ],
      [
         '1 -> 2 -> 3 -> 4 -> 5',
         '6 -> 5 -> 5',
         '1 -> 3 -> 0 -> 0 -> 0',
      ],
      [
         '9 -> 8 -> 7',
         '1 -> 3',
         '1 -> 0 -> 0 -> 0',
      ];

   for @tests -> $test {
      my ($tl1, $tl2, $texp) = @$test;
      my $len = $test.map({$^s.chars}).max;
      my $l1 = LinkedList.create($tl1.split: /\s* '->' \s*/);
      is $l1.Str, $tl1, sprintf("  (%{$len}s)", $tl1);
      my $l2 = LinkedList.create($tl2.split: /\s* '->' \s*/);
      is $l2.Str, $tl2, sprintf("+ (%{$len}s)", $tl2);
      my $sum = $l1 + $l2;
      is $sum.Str, $texp, sprintf("= (%{$len}s)", $texp);
   }
   done-testing;
}
```

Also in this case we can find the *overloading* of the `+` operator,
although in a much more refined way. This is so cool. Or [Cool][]?

# Conclusion

Both programs give the same output as below:

```
ok 1 -   (1 -> 2 -> 3)
ok 2 - + (3 -> 2 -> 1)
ok 3 - = (4 -> 4 -> 4)
ok 4 -   (1 -> 2 -> 3 -> 4 -> 5)
ok 5 - + (          6 -> 5 -> 5)
ok 6 - = (1 -> 3 -> 0 -> 0 -> 0)
ok 7 -   (     9 -> 8 -> 7)
ok 8 - + (          1 -> 3)
ok 9 - = (1 -> 0 -> 0 -> 0)
1..9
```

which is what we were expecting!

What to say more? Thanks to [manwar][] for another week of fun, and stay
safe everyone!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#129]: https://theweeklychallenge.org/blog/perl-weekly-challenge-129/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-129/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[Cool]: https://docs.raku.org/type/Cool
