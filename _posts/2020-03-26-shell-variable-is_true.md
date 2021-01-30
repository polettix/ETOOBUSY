---
title: 'Shell variables tests: is it true?'
type: post
tags: [ shell, coding ]
series: Shell Tricks
comment: true
date: 2020-03-26 23:33:01 +0100
published: true
---

**TL;DR**

> Let's continue with our shell test functions, this time understanding
> whether a variable is *true* or *false*.

# Definitions

Let's first state what we consider *true*: whatever [Perl][] thinks of it.
So:

- an *undefined* variable is *false* (see [Shell variables tests: is it
  defined?][svt-defined] for our definition of *defined* and *undefined*);
- an *empty* variable is *false*;
- `0` is *false*;
- everything else is *true*.

Let's define a few test variables:

```shell
unset F_UNSET
F_EMPTY=''
F_ZERO=0
T_ONE=1
T_WHATEVER='whatever'
```

# Normalizing undefined variables

One thing that we have to be careful is applying test to an undefined
variable, because the shell might have been set to be very picky about this.
To this regard, it's useful to look at [parameter expansion][]:

> `${parameter:-[word]}`
>
> **Use Default Values**. If __parameter__ is unset or null, the expansion
> of __word__ (or an empty string if word is omitted) shall be substituted;
> otherwise, the value of parameter shall be substituted.

Hence, we can use `0` as the default value, so whatever variable state we
start from, *false* state will always be represented as `0`, simplifying the
test.

# The test

These are two functions to implement that test:

```shell
is_var_true() {
   local value
   eval 'value="${'"$1"':-"0"}"'
   [ "$value" != '0' ]
}
is_value_true() {
   [ $# -gt 0 ] || return 1    # empty input list -> false
   [ "${1:-"0"}" != '0' ]
}
```

The first tests whether a *variable* is *true* or *false*:

```
$ for v in F_UNDEF F_EMPTY F_ZERO T_ONE T_WHATEVER ; do
   is_var_true "$v" && printf '%s: true\n' "$v" || printf '%s: false\n' "$v"
done

F_UNDEF: false
F_EMPTY: false
F_ZERO: false
T_ONE: true
T_WHATEVER: true
```

The second tests whether the value of the first input parameter (if any) is
*true* or *false*:

```shell
$ is_value_true "$F_EMPTY" && printf 'F_EMPTY: true\n' || printf 'F_EMPTY: false\n'
F_EMPTY: false

$ is_value_true "$F_ZERO" && printf 'F_ZERO: true\n' || printf 'F_ZERO: false\n'
F_ZERO: false

$ is_value_true "$T_ONE" && printf 'T_ONE: true\n' || printf 'T_ONE: false\n'
T_ONE: true

$ is_value_true "$T_WHATEVER" && printf 'T_WHATEVER: true\n' || printf 'T_WHATEVER: false\n'
T_WHATEVER: true
```

Sounds like the functions work!

[Perl]: https://www.perl.org/
[parameter expansion]: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02
[svt-defined]: {{ '/2020/03/25/shell-variable-is_defined/' | prepend: site.baseurl | prepend: site.url }}
