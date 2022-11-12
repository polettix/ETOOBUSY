---
title: Looking at Beancount
type: post
tags: [ accounting ]
comment: true
date: 2021-10-18 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I started looking at [Beancount][] after [Doubting about
> Accounting::Kitty][].

After doubting, I had to look more in depth into the alternatives.
Inside the [Ledger & co.][] heap I chose [Beancount][], which is
supposed to be *stricter* in doing checks.

I'm not entirely sure how I should model a kitty though. Ideally, we
have a box with some money inside (the *kitty*), which is contributed by
a few people (let's say Alice, Bob, and Carol) for some common goal
(e.g. buy groceries and other stuff during a vacation).

In addition to this:

- expenses might be split differently, depending e.g. on what is bought
  (as an example, Bob might ask to get an ice cream to eat on the spot
  while buying common groceries)
- sometimes, people might spend some money out of their personal pocket
  because they don't have the box around, but they're fine to *not* get
  the money back phisically and just track this somehow.
- sometimes people might want to put money in the kitty because they can
  or want to do so.

For these reasons, the amount of money in the kitty belongs to Alice,
Bob, and Carol in different amounts.

There's more: if the kitty is not a physical box, but a shared bank
account, our heroes will need to keep track of the expenses by
onboarding statements from the bank.

All of this can be tracked by `Accounting::Kitty` in this way:

- whatever exchange of money in the bank statements happens between a
  `Common` account and an `External` account. Examples:
    - An expense is paid throught the bank account? That's money going
      from `Common` to `External`.
    - Alice orders a wire transfer from her personal banck account to
      the shared bank account? That's money going from `External` to
      `Common`
- money in `Common` should not remain there unaccounted for long:
    - an outflow of money is typically due to an expense. This might be
      all on one of the participants, or on all of them in equal or
      specific quotas. This means that money goes from each
      participants' accounts towards `Common`, in order to balance the
      expense
    - an inflow of money is typically a wire transfer or e.g. some
      refund. The same rules apply: this money generally goes into each
      of the participants' accounts in different quotas, depending on
      the situation.

As an example, suppose that Alice orders a wire transfer of 100 EUR from
her bank account towards the shared bank account. The bank statement
will register this as an *increase* in money of the shared account,
which can be translated into this transation:

```
1. External --> Common: 100 EUR
```

If we were starting from all zeroes, we have the following situation:

```
External -100 EUR
Common    100 EUR
Alice       0 EUR
Bob         0 EUR
Carol       0 EUR
```

As we were saying, money should not remain unaccounted in `Common`, so
we have to decide whose are those 100 EUR or, more exactly, where should
that transaction fall. In this case we know it's all Alice's money, so
our transactions log becomes:

```
1. External --> Common: 100 EUR
2. Common   --> Alice:  100 EUR 
```

This leads us to this state:

```
External -100 EUR
Common      0 EUR
Alice     100 EUR
Bob         0 EUR
Carol       0 EUR
```

Now, let's suppose that Bob and Carol do similar wire transfers:

```
1. External --> Common: 100 EUR
2. Common   --> Alice:  100 EUR 
3. External --> Common:  90 EUR
4. External --> Common: 120 EUR
5. Common   --> Bob:     90 EUR
6. Common   --> Carol:  120 EUR
```

This makes us end up with this:

```
External -310 EUR
Common      0 EUR
Alice     100 EUR
Bob        90 EUR
Carol     120 EUR
```

A shared expense will appear as a withdrawal of money from the bank
account, like this:

```
1. External --> Common:   100 EUR
2. Common   --> Alice:    100 EUR 
3. External --> Common:    90 EUR
4. External --> Common:   120 EUR
5. Common   --> Bob:       90 EUR
6. Common   --> Carol:    120 EUR
7. Common   --> External:  60 EUR
```

Now this is the situation:

```
External -250 EUR
Common    -60 EUR
Alice     100 EUR
Bob        90 EUR
Carol     120 EUR
```

If the expense has to be split in equal parts, then we record three more
transactions about this:

```
 1. External --> Common:   100 EUR
 2. Common   --> Alice:    100 EUR 
 3. External --> Common:    90 EUR
 4. External --> Common:   120 EUR
 5. Common   --> Bob:       90 EUR
 6. Common   --> Carol:    120 EUR
 7. Common   --> External:  60 EUR
 8. Alice    --> Common:    20 EUR
 9. Bob      --> Common:    20 EUR
10. Carol    --> Common:    20 EUR
```

This brings `Common` back to 0:

```
External -250 EUR
Common      0 EUR
Alice      80 EUR
Bob        70 EUR
Carol     100 EUR
```

Last, suppose that Alice buys some groceries out of her pocket, for 30
EURs to be split evenly.

One way is to model this with two transactions, one from Bob and one
from Carol, with their amount directly back to Alice:

```
11. Bob   --> Alice: 10 EUR
12. Carol --> Alice: 10 EUR
```

This loses track of the specific expense, though, so it would be useful
to do otherwise. Another way is to model it with a transfer from
`Common` to `Alice`, and then the three of them will replenish whatever
makes `Common` not to be 0:

```
11. Common --> Alice:  30 EUR
12. Alice  --> Common: 10 EUR
13. Bob    --> Common: 10 EUR
14. Carol  --> Common: 10 EUR
```

A third way is to reason like this: it's like Alice puts the money in
the kitty, the expense is done for the same amount, then the three split
the expense:

```
11. External --> Common:   30 EUR
12. Common   --> Alice:    30 EUR
13. Common   --> External: 30 EUR
14. Alice    --> Common:   10 EUR
15. Bob      --> Common:   10 EUR
16. Carol    --> Common:   10 EUR
```

It's basically the same as before, only with two added transactions to
make it clearer why the transfer from `Common` to Alice.

Whatever, the end state is the same:

```
External -250 EUR
Common      0 EUR
Alice     100 EUR
Bob        60 EUR
Carol      90 EUR
```

So... I just have to figure out how to model this with [Beancount][] 🙄

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Beancount]: https://beancount.github.io/docs/index.html
[Doubting about Accounting::Kitty]: {{ '/2021/10/17/kitty-is-it-worth/' | prepend: site.baseurl }}
[Ledger & co.]: {{ '/2021/09/18/ledger/' | prepend: site.baseurl }}
