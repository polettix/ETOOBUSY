---
title: 'Why splitting if you can point?'
type: post
tags: [ rakulang, perl weekly challenge ]
comment: true
date: 2021-09-12 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Operator overloading in [Raku][] is cool.

I must have done some very good things in a past life, because I
received the blessing of getting high quality hints from [gfldex][] from
time to time. Keep up with the good work, Flavio!

This time I got a nice interface design suggestion about 
[PWC129 - Add Linked Lists][], where my tests were structured like this:

```
my @tests =
   [
      '1 -> 2 -> 3', # input #1, as a string
      '3 -> 2 -> 1', # input #2, as a string
      '4 -> 4 -> 4', # expected output, as a string
   ],
   ...
```

The first two strings in each string have first to be split to only get
the values in the list, then the resulting list used to initialize a `LinkedList`:


```raku
my $l1 = LinkedList.create($tl1.split: /\s* '->' \s*/);
```

[gfldex][] challeges the approach: why the `split` when you can *point*?
Something like this:

```raku
my @tests =
   [
      1 → 2 → 3,
      1 → 2 → 3,
      '4 -> 4 -> 4',
   ],
...

my ($l1, $l2, $sumstr) = @$test;
is ($l1 + $l2).Str, $sumstr, "sum leading to $sumstr";
```

The result is still expressed as a string (`$sumstr`), because we want
to use the *stringification* to check against the result!

The good thing is that I also got a hint about the implementation,
without getting all of it:

```raku
multi sub infix:«→»(List \l, \r) {
    |l, |r
}

multi sub infix:«→»(\l, \r) {
    l, r;
}
```

Of course we're not dealing with the real `LinkedList` in the examples
above, but the suggestion is easy to follow:

```raku
multi sub infix:«→» (*@ls) is assoc<list> {
   return LinkedList.create(@ls) unless @ls[*-1] ~~ LinkedList;
   return @ls.reverse.reduce: -> $t, $h { $t.insert($h); $t };
}
```

Well... maybe I'm still a bit attached to my [Perl][] accent, so there
is actually no need for `multi` here, and I'm doing some dispatching
inside the sub instead of using the `multi` mechanism. In this case,
though, my point is that I don't know how to put a *slurpy* argument
element that takes all *but* the last element 🙄

Here I'm addressing two different cases:

- adding one or more elements to a pre-existing list;
- creating a new list from scratch (i.e. a list of elements).

My first implementation was actually leveraging `multi`:

```raku
multi sub infix:«→» ($h, LinkedList $t) is assoc<right> {
   $t.insert($h);
   return $t;
}
multi sub infix:«→» ($h, $t) is assoc<right> {
   return LinkedList.create($h, $t);
}
```

but you know... I was thinking about using a whole list all at once and
avoid calling the sub too many times.

There's a slight thing that I'm not entirely happy about, that is we are
adding new elements *from the left*. This might be a bit *surprising*...
in general, I would expect this kind of operation to produce a *new
list*, keeping the old one untouched.

Anyway, with this... tests might be compressed in a single line:

```raku
is ((1 → 2 → 3) + (3 → 2 → 1)).Str, '4 -> 4 -> 4', 'single test yay!';
```

Isn't this *cool*?!?

Thanks [gfldex][] for keeping the suggestions flow... and stay safe
everyone!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[gfldex]: https://gfldex.wordpress.com/
[PWC129 - Add Linked Lists]: {{ '/2021/09/09/pwc129-add-linked-list' | prepend: site.baseurl }}
