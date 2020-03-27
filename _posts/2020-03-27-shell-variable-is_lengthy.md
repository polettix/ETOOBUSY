---
title: 'Shell variables tests: is it lengthy?'
type: post
tags: [ shell, coding]
comment: true
date: 2020-03-27 01:50:05 +0100
published: true
---

**TL;DR**

> Let's look at a test to understand whether a variable is defined and not
> empty - what we can call *lengthy*.

Sometimes in a shell function we want to check that a non-empty parameter
was passed in, or that a variable is populated with a non-empty value. The
following functions help to this regard:

```shell
is_var_lengthy() {
   local value
   eval 'value="${'"$1"':-""}"'
   [ -n "$value" ]
}
is_value_lengthy() { [ $# -gt 0 ] && [ -n "$1" ] ; }
```

If they seem similar to the functions in [Shell variables tests: is it
true?][svt-true]... they are 😎

Let's see some examples, based on the following variables:

```shell
unset UNDEF
EMPTY=''
LENGTHY='whatever'
```

First, let's see `is_var_lengthy`:

```shell
$ for v in UNDEF EMPTY LENGTHY ; do
   is_var_lengthy "$v" && printf '%s: lengthy\n' "$v" || printf '%s: empty\n' "$v"
done

UNDEF: empty
EMPTY: empty
LENGTHY: lengthy
```

Now, let's look at `is_value_lengthy`, including a case where we pass an
empty argument list:

```shell
$ is_value_lengthy "$EMPTY" && printf 'EMPTY: lengthy\n' || printf 'EMPTY: empty\n'
EMPTY: empty

$ is_value_lengthy "$LENGTHY" && printf 'LENGTHY: lengthy\n' || printf 'LENGTHY: empty\n'
LENGTHY: lengthy

$ is_value_lengthy && printf '(no args): lengthy\n' || printf '(no args): empty\n'
(no args): empty
```

They work pretty well!

[svt-true]: {{ '/2020/03/26/shell-variable-is_true/' | prepend: site.baseurl | prepend: site.url }}
