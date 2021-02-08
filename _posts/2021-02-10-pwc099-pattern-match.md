---
title: PWC099 - Pattern Matching
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-02-10 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#099][]. Enjoy!

# The challenge

> You are given a string `$S` and a pattern `$P`. Write a script to
> check if given pattern validate the entire string. Print 1 if pass
> otherwise 0. The patterns can also have the following characters:
>> - ? - Match any single character.
>> - \* - Match any sequence of characters.

# The questions

Just a few assumptions that would turn into questions pretty quickly:

- I'll assume no special characters apart from those indicated;
- There is no mechanism of escaping any character inside the pattern
  string;
- characters equal bytes.

# The solution

We will leverage the huge flexibility of regular expressions for this
task. In regular expression terms, we have that...

- `.` matches any single character, just like we are asked to do with
  `?`;
- `.*` matches any lenght sequence of whatever character, just like we
  are asked to do with `*`.
- other special characters might have a meaning in the regular
  expression, so we have to *passivate* them.

Here is our function:

```perl
sub pattern_match ($S, $T) {
   $T = join '',
      map { $_ eq '*' ? '.*' : $_ eq '?' ? '.' : quotemeta($_) }
      split m{([*?])}mxs, $T;
   return $S =~ m{\A$T\z}mxs ? 1 : 0;
}
```

To get all instances of either `?`or `*` we use a `split` that does also
include the separators in the output. At this point, it suffices to use
the special characters as the regular expression to look for, and we
will have split our string in a list of items that are either without
the two special characters, or a single special character.

Each item in this list is then transformed:

- the two special characters into their regular expressions counterpart;
- other items are passed through `quotemeta`, in order to *passivate+
  any special character that might be recognized in a regular
  expression.

After this, we are left with a list of items that are either the right
translation for the challenge's special characters, or have no special
character at all inside (from a regular expression point of view).
Joining all these parts together gives us a regular expression ready for
matching.

Well... not so fast! We are asked to check the *whole* string, so the
actual match is done making sure to also set the anchors for the start
of the string (`\A`) and the end of it (`\z`). At this point, the match
gives us the needed answer.

Nice!


[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#099]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-099/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-099/#TASK1
[Perl]: https://www.perl.org/
