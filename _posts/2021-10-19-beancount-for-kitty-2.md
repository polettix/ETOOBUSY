---
title: Beancount for Kitty, simple model
type: post
tags: [ accounting ]
comment: true
date: 2021-10-19 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A simple model of a kitty for [Beancount][].

After laying down the needs in [Looking at Beancount][], I went for a
direct mapping of the different accounts, setting most of them as Assets
and the `External` one as an Equity:

```
2021-01-01 open Assets:Common   EUR
2021-01-01 open Assets:Alice    EUR
2021-01-01 open Assets:Bob      EUR
2021-01-01 open Assets:Carol    EUR
2021-01-01 open Equity:External EUR
```

Now, let's recap the first transactions, where the three participants do
a wire transfer to the common account:

```
 1. External --> Common:   100 EUR
 2. Common   --> Alice:    100 EUR 
 3. External --> Common:    90 EUR
 4. External --> Common:   120 EUR
 5. Common   --> Bob:       90 EUR
 6. Common   --> Carol:    120 EUR
```

Their mapping to [Beancount][] is straightforward:

```
2021-01-01 * "wire transfer from Alice, from the bank"
   Assets:Common   100 EUR
   Equity:External

2021-01-01 * "attribution to Alice"
   Assets:Alice  100 EUR
   Assets:Common

2021-01-02 * "wire transfer from Bob, from the bank"
   Assets:Common   90 EUR
   Equity:External

2021-01-02 * "wire transfer from Carol, from the bank"
   Assets:Common   120 EUR
   Equity:External

2021-01-03 * "attribution to Bob"
   Assets:Bob    90 EUR
   Assets:Common

2021-01-03 * "attribution to Carol"
   Assets:Carol  120 EUR
   Assets:Common
```

Now the expenses directly from the common account:

```
 7. Common   --> External:  60 EUR
 8. Alice    --> Common:    20 EUR
 9. Bob      --> Common:    20 EUR
10. Carol    --> Common:    20 EUR
```

These can be represented with two records, one related to what comes
from the bank statement, the other one for the splitting:

```
2021-01-20 * "buying something for the group, via the bank"
   Assets:Common -60 EUR
   Equity:External

2021-01-20 * "splitting the expense"
   Assets:Alice  -20 EUR
   Assets:Bob    -20 EUR
   Assets:Carol  -20 EUR
   Assets:Common
```

Last the direct expense from Alice (let's stick to the simpler model):

```
11. Common --> Alice:  30 EUR
12. Alice  --> Common: 10 EUR
13. Bob    --> Common: 10 EUR
14. Carol  --> Common: 10 EUR
```

This can be addressed in one single recording:

```
2021-01-27 * "Alice buying something directly"
   Assets:Alice  30 EUR
   Assets:Alice -10 EUR
   Assets:Bob   -10 EUR
   Assets:Carol -10 EUR
```

So... let's see how it goes:

```
$ bean-report example.bc balances
Assets:Alice       100 EUR
Assets:Bob          60 EUR
Assets:Carol        90 EUR
Assets:Common   
Equity:External   -250 EUR
Expenses        
Income          
Liabilities
```

It's working, which is fair. I'm not sure it's the best way to model the
whole thing... but it's surely one!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Looking at Beancount]: {{ '/2021/10/18/beancount-for-kitty/' | prepend: site.baseurl }}
[Beancount]: https://beancount.github.io/docs/index.html
