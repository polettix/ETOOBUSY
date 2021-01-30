---
title: 'Shell variables tests: is it defined?'
type: post
tags: [ shell, coding ]
series: Shell Tricks
comment: true
date: 2020-03-25 07:27:52 +0100
published: true
---

**TL;DR**

> Finding out if an environment variable is defined, in the shell.


# Definitions

First of all, here's what I mean:

- *undefined*: when the variable is not set;
- *defined*: when the variable is set, which has two sub-cases:
  - *empty*: when the variable is set to an empty string (this is also
    referred to as *null*);
  - other: anything that has length greater than 0.

Note that an *empty* (or *null*) variable is *defined*.

We will assume the following in the examples below:

```shell
unset UNDEF
EMPTY=''
LENGTHY='whatever'
```

# Basic trick

We start from the *Use Alternate Value* in [parameter expansion][]:

> `${parameter:+word}
>
> **Use Alternate Value**. If __parameter__ is null or unset, nothing is
> substituted, otherwise the expansion of __word__ is substituted.

Test time:

```shell
$ printf "UNDEF<${UNDEF:+X}> EMPTY<${EMPTY:+X}> LENGTHY<${LENGTHY:+X}>\n"
UNDEF<> EMPTY<> LENGTHY<X>
```

Almost there, we can tell non-empty strings apart, but undefined strings are
treated the same as empty ones. Anyway, [parameter expansion][] also has
this:

> In the parameter expansions shown previously, use of the <colon> in the
> format shall result in a test for a parameter that is unset or null;
> omission of the <colon> shall result in a test for a parameter that is
> only unset.

So, it seems that we only have to get rid of the colon:

```shell
$ printf "UNDEF<${UNDEF+X}> EMPTY<${EMPTY+X}> LENGTHY<${LENGTHY+X}>\n"
UNDEF<> EMPTY<X> LENGTHY<X>
```

This is what we were looking for: undefined variables are turned into an
empty string, defined variables are turned into the provided string `X`.

# Adding readability

The basic trick is not the most readable thing in the world... nor the
easier to remember. For me at least. This is why I prefer to embed the trick
in a function:

```shell
is_var_defined () { eval "[ -n \"\${$1+ok}\" ]" ; }
```

The assumption in the above function is that the *variable name* is passed
as the first parameter - this implies using an `eval` to make things work.

Test time:

```shell
$ is_var_defined UNDEF && printf 'defined\n' || printf 'undefined\n'
undefined

$ is_var_defined EMPTY && printf 'defined\n' || printf 'undefined\n'
defined

$ is_var_defined LENGTHY && printf 'defined\n' || printf 'undefined\n'
defined
```

This is it for today!


[parameter expansion]: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02
