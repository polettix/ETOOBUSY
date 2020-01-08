---
title: Grep o Treat
type: post
tags: [ grep, shell, terminal, regex ]
comment: true
date: 2020-01-01 09:08:48 +01:00
---

**TL;DR**

> there is more to [GNU grep][] than what I thought for a long time,
> including the possibility to avoid using [sed][] from time to time.

<script id="asciicast-291236" src="https://asciinema.org/a/291236.js" data-speed="1.5" async></script>

I guess everybody has those nice little *Today I Learnt...* moments every
now and then. This happened to me not too much time ago, reading some
article that used [GNU grep][] in a way that's not seen everyday. And, by
the way, that's not portable (i.e. not supported in [POSIX grep][]), if
you're wondering.

## A Couple Of Interesting Options

[GNU grep][] provides a couple of interesting command-line options, like these:

- `-o`: prints out only the *matched test*, instead of the whole line that
  includes it. So, if you're looking for IP Addresses in some text that
  you're fine to search with a simplified, approximate regex you can do
  something like this:

~~~~
grep -o '[0-9]\+\(\.[0-9]\+\)\{3\}' <input.txt
~~~~

- `-P`: activate the mighty engine for Perl-Compatible Regular Expressions
  (a.k.a. [PCRE][]). This basically boils down to using [Perl][]'s
  regular expressions, which provide much more flexibility. The previous
  example would become:

~~~~
grep -Po '\d+(\.\d+){3}' <input.txt
~~~~

## Also, `\K` Can Save The Day

Using [PCRE][] gives much more than just less backslashes or shortcuts for
matching digits; some of the adds-on play particularly well with option
`-o`.

One such feature is `\K`, which resets the match start to where it is put.
Let's see an example.

Suppose that you're looking for the *right* IP Address in your input, the
one that is preceded by the word "right". This can of course be
accomplished by just putting the additional constraint in the regular
expression:

~~~~
grep -Po 'right \d+(\.\d+){3}' <input.txt
~~~~

Alas, this kind of defies the usefulness of `-o` though, because now we
also get `right ` in the output! This is where `\K` comes to the rescue:

~~~~
grep -Po 'right \K\d+(\.\d+){3}' <input.txt
~~~~

This tells that a successful match *MUST* include `right ` as we wish, but
for the purpose of setting the *matched string*, everything before `\K`
must be ignored. So we are back to our IP-address-only output like before.

## And `\b`, Of Course

Another interesting escape sequence enabled by [PCRE][] is `\b`, that is
a zero-width match for a word boundary.

In our example, suppose that your file might also contain IP Addresses
that are adjacent to words, like this:

~~~~
this is not right 10.20.1.230bis
...
this is right 10.1.12.34
~~~~

To tell the two situations apart, we can just require that our approximate
pattern for IP addresses ends on a word boundary:

~~~~
grep -Po 'right \K\d+(\.\d+){3}\b' <input.txt
~~~~

## Today I Learnt...

... that [grep][POSIX grep] + [sed][] is a wonderful and powerful
combination, but sometimes [GNU grep][] alone can do wonders.


[GNU grep]: https://www.gnu.org/software/grep/
[sed]: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/sed.html
[POSIX grep]: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/grep.html
[PCRE]: https://www.pcre.org/
[Perl]: https://www.perl.org/
