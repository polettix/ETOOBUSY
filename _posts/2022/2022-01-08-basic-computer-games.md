---
title: Updating The Single Most Influential Book of the BASIC Era
type: post
tags: [ basic, perl, retro ]
comment: true
date: 2022-01-08 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Yet another way to **use** time.

I stumbled upon [Updating The Single Most Influential Book of the BASIC
Era][updating] and it struck a cord! Because yes, I'm in that age range where I
learned to program in BASIC on a Commodore 64, so looking at BASIC
programs from 70s and 80s definitely strucks a cord.

The due citation from [How do we tell truths that might hurt?][] by the
late [prof.dr.Edsger W.Dijkstra][] first:

> It is practically impossible to teach good programming to students
> that have had a prior exposure to BASIC: as potential programmers they
> are mentally mutilated beyond hope of regeneration.

Well, we'll have to stick to *bad* programming then!

Anyway.

The project in [Updating...][updating] is simple. There's the book, and
[Jeff Atwood][]'s goal:

> I think we owe it to the world to bring this book up to date using
> **modern, memory safe languages that embody the original spirit of
> BASIC**, and modern programming practices including subroutines.

So I ate the bait and was caught! I took a look around and got
interested into [Awari][], because I played a version of the game at the
time and also because I'm fond of board games.

And folks, what a gem! In 70 lines of BASIC, we get:

- a working program!
- a smart computer adversary!
- artificial intelligence!
- machine learning!

Yes, machine learning too: every time the program *does not win* (i.e.
also when it draws), it considers this a failure and keeps track of this
to investigate alternative moves and try *not* to lose again when the
situation arises again. Chapeau!

So there we go, I did a translation of the [BASIC][] code into [Perl][]
and you can find it [in the project][]. It strives to keep the *spirit*
and the behaviour of [the original BASIC code][] (which, by the way, can
be run using [Vintage BASIC][]) and contains plenty of comments, so I'll
not repeat this here.

Well, maybe a comment or two... about the computer adversary.

First, it works well although its calculation of the "future gain" is
somehow questionable. In particular, the calculation of the player's
response is not faithful in my opinion:

```
825 L=B(I)+I:R=0
830 IF L>13 THEN L=L-14:R=1:GOTO 830
835 IF B(L)=0 THEN IF L<>6 THEN IF L<>13 THEN R=B(12-L)+R
```

Variable `R` keeps track of the player's utility. It starts from `0` at
line 825, and it is increased by 1 in line 830 if the last landing pit
`L` is greater than 13, i.e. it goes around.

I have two objections to this:

- first, for the player to gain a seed in their home pit, the landing
  position needs to be greater or equal to 6 (i.e. the seventh pit), not
  13;
- if anything, landing on 13 or more should yield a 0, because the
  player would gain a point, but the computer would gain a point too.

For this reason, the proposed [Perl][] porting [has this
instead][player-score] (variable `$p_score` is the equivalent of `R`):

```perl
my $p_score = $ENV{ORIGINAL} ? $landing > 13
   : ($landing + 1) % 14 > 6;
```

The `ORIGINAL` environment variable allows preserving the behaviour in
the original `BASIC`implementation, otherwise the *correct*
implementation sets the player's score to 1 if it needs to, i.e. if the
landing position falls between the seventh and the thirteenths pit.

Line 835 correctly increases the player's expected revenue in case
conditions apply, so it's OK!

The second consideration is about how the history of *failed* matches is
tracked. The original BASIC implementation adopts a clever encoding
based on integers, which is capable of recording up to 9 moves
(otherwise an overflow would occur). In the translation, I thought it
better to adhere to the *spirit* of the algorithm, and not necessarily
its implementation and its restrictions. So I'm using a string of test,
which records the sequence of moves done by the player and the computer:

```perl
my $moves = '/';
...
$moves .= "$move/";
```

When needed, this string is compared against the "history" of past
matches:

```perl
for my $failure ($failures->@*) {
   ...
   next if index($failure, $candidate_moves) != 0;
   ...
}
```

Using `index()` here, and comparing the result against 0, means that we
have a correspondence with a past failed match only if the hypothetical
sequence of `$candidate_moves` is the same as the start of the recorded
match in `$failure`. Otherwise, `index()` either returns -1 (if there is
no inclusion of `$candidate_moves` inside `$failure`) or a value greater
than 1 (if it is included, but later into the string); in both cases,
we're not talking about the same sequence of moves, and we can ignore
it.

So... intrigued? Why not contribute another porting? Stay safe anyway!

[Perl]: https://www.perl.org/
[BASIC]: https://en.wikipedia.org/wiki/BASIC
[Vintage BASIC]: http://vintage-basic.net/
[updating]: https://blog.codinghorror.com/updating-the-single-most-influential-book-of-the-basic-era/
[How do we tell truths that might hurt?]: https://www.cs.utexas.edu/users/EWD/transcriptions/EWD04xx/EWD498.html
[prof.dr.Edsger W.Dijkstra]: https://www.cs.utexas.edu/users/EWD/
[Jeff Atwood]: https://blog.codinghorror.com/about-me/
[Awari]: https://github.com/coding-horror/basic-computer-games/tree/main/04_Awari
[in the project]: https://github.com/coding-horror/basic-computer-games/blob/main/04_Awari/perl/awari.pl
[the original BASIC code]: https://github.com/coding-horror/basic-computer-games/blob/main/04_Awari/awari.bas
[player-score]: https://github.com/coding-horror/basic-computer-games/blob/7c37a8eeb4908da63036bbd0dcb1196fefee1478/04_Awari/perl/awari.pl#L193
