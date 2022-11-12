---
title: Resuming an old module
type: post
tags: [ perl, accounting ]
comment: true
date: 2021-09-14 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Resuming an old module to do some accounting.

I have a system with my wife where we split most expenses that we do
together. It was born to split things fairly - i.e. to avoid that any of
us could have the *feeling* of not contributing enough. I know, I know.

Anyway, I modeled the whole thing as a ledger where the total sum of
things is... zero. There are a few *accounts* that can contain, give or
receive resources (well, money!) and all operations are about moving a
quantity X from account A to account B, possibly with a reason.

I keep four accounts:

- one for my wife (`Foo`) and one for me (`Bar`);
- one modeling us as a single entity (`Common`);
- one modeling the external world (`External`).

Something happening in the real world has its counterpart in this
accounting system. A few examples:

- getting 100 € in our shared account in the bank, e.g. a gift from
  someone, means transferring 100 € from `External` to `Common`. Hence,
  `External` becomes *poorer* by 100 €, and it's right: this money is
  now in our `Common` assets;
- splitting those 100 € in half means two operations:
    - moving 50 € from `Common` to `Foo`
    - moving 50 € from `Common` to `Bar`

Net result is that `Common` is back to 0 €, `External` is poorer by 100
€ and both of us are richer by 50 €.

- paying a bill of 200 € is a transfer from `Common` to `External`,
  creating a *void* of 200 € in `Common` (i.e. it is now at -200 €);
- splitting the bill among us means doing two transfers, which depend on
  how we split. E.g. if I pay 60% of that bill, it means the following
  two transactions:
    - moving 80 € from `Foo` to `Common`
    - moving 120 € from `Bar` to `Common`.

Again, the `Common` part goes back to 0 €, which means that each euro
has been attributed to either of us.

The interesting thing with this is that our common bank account (but it
might just as well be a pocket containing shared money) is always
represented by the `External` account with the changed sign: a negative
value for `External` means that there is actual money in the pocket,
while a positive value means that we owe the external world money.

I started implementing a [Perl][] module to capture this, and later
forgot about it. As I resumed the idea, I see that the implementation
was (is?) quite complete, also including a lot of tests.

So I hope I'll resume this project in a proper way, and release to
[CPAN][] as soon as possible.

Stay safe folks!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[CPAN]: https://metacpan.org/
