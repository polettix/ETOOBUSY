---
title: PWC180 - First Unique Character
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-09-01 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#180][]. Enjoy!

# The challenge

> You are given a string, `$s`.
>
> Write a script to find out the first unique character in the given
> string and print its index (0-based).
>
> **Example 1**
>
>     Input: $s = "Perl Weekly Challenge"
>     Output: 0 as 'P' is the first unique character
>
> **Example 2**
>
>     Input: $s = "Long Live Perl"
>     Output: 1 as 'o' is the first unique character

# The questions

I guess that we have to decide *how* we get the string, taking care of
whatever encoding stuff we can think of.

And, of course, that the *character* we mean whatever Unicode character
we can think of, and more.

And, oh-by-the-way, that the whole string is going to fit nicely in
memory, while still leaving us space to do our stuff.

# The solution

A few days ago I read [a tweet like this][tweet]:

> Q: what's s double linked list?
>
> A: a data structure only used in interviews

I had a good laugh and thought that, in my case, it was *sort of* true,
in the sense that I could not remember using linked lists (or their
grown-up sister, the *doubly-linked list*) anywhere else than university
excercises in the nineties.

But, of course, the wheel goes round and round and here I find a
challenge (mind you, *not* an interview question!) where a doubly-linked
list fits perfectly. Never say never.

This said, here's the plan:

- we will have to iterate over all input characters. With the whole
  power of Unicode at our input builder's disposal, it would not make
  sense to try and optimize for the case *well I've already seen all of
  them at least twice, I guess I can just bail out*. (This was, by the
  way, my original plan when I believed that ASCII letters were at play
  only).
- we keep track of whatever we have already encountered in a hash, where
  the key is the character and the value can be one of:
  - the index in the string at which we first saw the character, OR
  - the undefined value (`Nil` or `undef`, depending on the language) if
    we meet the character beyond the first time.
- we also keep track of any new character's index in a shiny
  *doubly-linked list*, with the convention that we remove the slot for
  a character as soon as we meet it the second time.

At the end of the iteration, the doubly-linked list can be either empty
(i.e. every character was repeated at least once) or not, so we just
have to consider the first element and we're done.

Let's start with [Raku][] first, where we go all-in with classes, using
even a class within another class. I am moderately surprised to have
encountered very few roadblocks while coding this.

```raku
#!/usr/bin/env raku
use v6;

class DoubleLinkedList { ... }
sub MAIN ($string = 'Perl Weekly Challenge') {
   my $order = DoubleLinkedList.new;
   my %dll-element-for;
   my $i = 0;
   for $string.comb -> $character {
      if %dll-element-for{$character}:exists {
         if defined %dll-element-for{$character} {
            $order.remove(%dll-element-for{$character});
            %dll-element-for{$character} = Nil;
         }
      }
      else {
         %dll-element-for{$character} = $order.push($i).tail;
      }
      ++$i;
   }

   die 'no result, sorry!' unless defined $order.head;
   put $order.head.value;
}

class DoubleLinkedList {
   class Element {
      has $.value;
      has $.pred is rw is built = Nil;
      has $.succ is rw is built = Nil;
   }

   has $.head is rw is built = Nil;
   has $.tail is rw is built = Nil;

   method push ($value) {
      my $element = Element.new(
         value => $value, pred => $.tail, succ => Nil);
      $.tail.succ = $element if defined $.tail;
      $.tail = $element;
      $.head //= $element;
      return self;
   }

   method remove ($element) {
      if (defined $element.pred) {
         $element.pred.succ = $element.succ;
      }
      else {
         $.head = $element.succ;
      }
      if (defined $element.succ) {
         $element.succ.pred = $element.pred;
      }
      else {
         $.tail = $element.pred;
      }
      return self;
   }
}
```

The [Perl][] alternative is very minimalistic. I'm avoiding the
`Element` class to just use an anonymous hash, at the end of the day
there's no real business logic in it.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use I18N::Langinfo qw(langinfo CODESET);
use Encode qw(decode);

{
   package DoubleLinkedList;
   sub new ($p) { return bless { head => undef, tail => undef }, $p }
   sub push ($self, $value) {
      my $e = { value => $value, pred => $self->{tail}, succ => undef };
      $self->{tail}{succ} = $e if defined $self->{tail};
      $self->{tail} = $e;
      $self->{head} //= $e;
      return $self;
   }
   sub remove ($self, $e) {
      if (defined $e->{pred}) { $e->{pred}{succ} = $e->{succ} }
      else                    { $self->{head} = $e->{succ}    }
      if (defined $e->{succ}) { $e->{succ}{pred} = $e->{pred} }
      else                    { $self->{tail} = $e->{pred}    }
      return $self;
   }
}

my $codeset = langinfo(CODESET);
my $string = decode($codeset, shift(@ARGV) // 'Perl Weekly Challenge');

my $order = DoubleLinkedList->new;
my %dll_element_for;
my $i = 0;
for my $character (split m{}mxs, $string) {
   if (exists $dll_element_for{$character}) {
      if (defined $dll_element_for{$character}) {
         $order->remove($dll_element_for{$character});
         $dll_element_for{$character} = undef;
      }
   }
   else {
      $dll_element_for{$character} = $order->push($i)->{tail};
   }
   ++$i;
}

die "no result, sorry!\n" unless defined $order->{head};
say $order->{head}{value};
```

I know that the [Perl][] "object system" is probably *too bare-bones*,
but it's amazing in these small programs.

Stay safe and unique!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#180]: https://theweeklychallenge.org/blog/perl-weekly-challenge-180/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-180/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[tweet]: https://twitter.com/jkolez/status/1564644664610697216
