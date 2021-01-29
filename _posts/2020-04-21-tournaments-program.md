---
title: Allocating games in tournaments - a program
type: post
tags: [ algorithm, game, maths, boardgamearena, perl, series:Tournaments games allocation ]
comment: true
date: 2020-04-21 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we take a look at a program to generate the complete schedule of
> tournaments with games with multiple players inside, providing an
> indication of need for premium ones if needed. Yay!

Not much to say, the code repository is here: [tournange][]. It basically
applies all considerations that we saw in the series of posts on
tournaments.

The following sections include arrangements for 3, 4, and 5 players, as well as
hints to use the program for 6 players per match. Use the program to generate
the other ones, like this:

```shell
# this is valid when $n is a prime power with exponent ≥ 1
$ n=2
$ tournange "$n"
round 1:
  (*1, *2)
  (*3,  4)

round 2:
  (*1, *3)
  (*2,  4)

round 3:
  (*1,  4)
  (*2, *3)

```

# Arrangement for 3 players

This is the arrangement for 3-players matches (9 players total, 5 premium
players if needed):

```
round 1:
  (*1, *2, *3)
  (*5,  7,  9)
  (*4,  6,  8)

round 2:
  (*1, *4, *5)
  (*3,  7,  8)
  (*2,  6,  9)

round 3:
  (*1,  6,  7)
  (*2, *5,  8)
  (*3, *4,  9)

round 4:
  (*1,  8,  9)
  (*3, *5,  6)
  (*2, *4,  7)
```

# Arrangement for 4 players

This is the arrangement for 4-players matches (16 players total, 7 premium
players if needed):

```
round 1:
  ( *1,  *2,  *3,  *4)
  ( *5,   8,  11,  14)
  ( *7,  10,  13,  16)
  ( *6,   9,  12,  15)

round 2:
  ( *1,  *5,  *6,  *7)
  ( *2,   8,  12,  16)
  ( *4,  10,  11,  15)
  ( *3,   9,  13,  14)

round 3:
  ( *1,   8,   9,  10)
  ( *2,  *5,  13,  15)
  ( *4,  *7,  12,  14)
  ( *3,  *6,  11,  16)

round 4:
  ( *1,  11,  12,  13)
  ( *4,  *5,   9,  16)
  ( *3,  *7,   8,  15)
  ( *2,  *6,  10,  14)

round 5:
  ( *1,  14,  15,  16)
  ( *3,  *5,  10,  12)
  ( *2,  *7,   9,  11)
  ( *4,  *6,   8,  13)
```

# Arrangement for 5 players

This is the arrangement for 5-players matches (25 players total, 9 premium
players if needed):

```
round 1:
  ( *1,  *2,  *3,  *4,  *5)
  ( *9,  13,  17,  21,  25)
  ( *7,  11,  15,  19,  23)
  ( *8,  12,  16,  20,  24)
  ( *6,  10,  14,  18,  22)

round 2:
  ( *1,  *6,  *7,  *8,  *9)
  ( *5,  13,  16,  19,  22)
  ( *3,  11,  17,  18,  24)
  ( *4,  12,  14,  21,  23)
  ( *2,  10,  15,  20,  25)

round 3:
  ( *1,  10,  11,  12,  13)
  ( *2,  *9,  14,  19,  24)
  ( *4,  *7,  16,  18,  25)
  ( *3,  *8,  15,  21,  22)
  ( *5,  *6,  17,  20,  23)

round 4:
  ( *1,  14,  15,  16,  17)
  ( *4,  *9,  11,  20,  22)
  ( *5,  *7,  10,  21,  24)
  ( *2,  *8,  13,  18,  23)
  ( *3,  *6,  12,  19,  25)

round 5:
  ( *1,  18,  19,  20,  21)
  ( *3,  *9,  10,  16,  23)
  ( *2,  *7,  12,  17,  22)
  ( *5,  *8,  11,  14,  25)
  ( *4,  *6,  13,  15,  24)

round 6:
  ( *1,  22,  23,  24,  25)
  ( *5,  *9,  12,  15,  18)
  ( *3,  *7,  13,  14,  20)
  ( *4,  *8,  10,  17,  19)
  ( *2,  *6,  11,  16,  21)
```

# Invoking for 6 players

As we saw, the 6-players matches case is trickier than the other ones, and
requires taking a decision. For this reason, you must provide an additional
parameter in this case:

```shell
$ tournange 6
For sixtets, please specify one of 'base', '7ok', or 'dup'

# use base, 7ok, or dup then
$ tournange 6 base
# ...
```

The solution is for 42 players total, playing either 7 matches (in the `base`
case), or 8 matches (`7ok` or `dup`). The number of premium players varies
depending on the case, too.

# And that's really all, folks!

This has been an interesting ride, let me know your thoughts in the comments
below!

If you want to take a look at all posts, here's the list:

- [Allocating games in tournaments][]
- [Allocating games in tournaments - example][]
- [Allocating games in tournaments - premium games and players][]
- [Allocating games in tournaments - 3 players practicalities][]
- [Allocating games in tournaments - 6 players matches][]
- [Allocating games in tournaments - 6 players matches, again][]
- [Allocating games in tournaments - 6 players matches, premium][]
- [Allocating games in tournaments - a program][]
- [Code repository][tournange]

[tournange]: https://gitlab.com/polettix/tournange
[Allocating games in tournaments - a program]: {{ '/2020/04/21/tournaments-program' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments - 6 players matches, premium]: {{ '/2020/04/20/tournaments-6-players-premium' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments - 6 players matches, again]: {{ '/2020/04/19/tournaments-6-players-again' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments - 6 players matches]: {{ '/2020/04/18/tournaments-6-players' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments - 3 players practicalities]: {{ '/2020/04/17/tournaments-3-practical' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments - premium games and players]: {{ '/2020/04/16/tournaments-premium' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments - example]: {{ '/2020/04/15/tournaments-example' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments]: {{ '/2020/04/14/tournaments' | prepend: site.baseurl | prepend: site.url }}
