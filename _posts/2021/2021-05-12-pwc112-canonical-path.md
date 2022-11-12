---
title: PWC112 - Canonical Path
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-05-12 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#112][]. Enjoy!

# The challenge


> You are given a string path, starting with a slash ‘/'.
> 
> Write a script to convert the given absolute path to the simplified canonical path.
> 
> In a Unix-style file system:
> 
> - A period '.' refers to the current directory
> - A double period '..' refers to the directory up a level
> - Multiple consecutive slashes ('//') are treated as a single slash '/'
> 
> The canonical path format:
> 
> - The path starts with a single slash '/'.
> - Any two directories are separated by a single slash '/'.
> - The path does not end with a trailing '/'.
> - The path only contains the directories on the path from the root directory to the target file or directory
> 
> Example
> 
>     Input: "/a/"
>     Output: "/a"
>     
>     Input: "/a/b//c/"
>     Output: "/a/b/c"
>     
>     Input: "/a/b/c/../.."
>     Output: "/a"

# The questions

As an amateur nitpicker, I would argue that the sentence *The path does
not end with a trailing '/'* is preetty inaccurate, because there might
well be an occasion where the trailing slash is needed... that is the
filesystem root `/`.

Anyway, apart from this the instructions are quite clear, so let's get
to the business!


# The solution

Here is my solution:

```perl
sub canonical_path ($p) {
   $p =~ s{/\K(?:\.?/)+}{}gmxs;
   $p =~ s{\A/.*\K/\z}{}mxs;
   1 while $p =~ s{/[^/]+/\.\.(/|\z)}{$1}mxs;
   return $p;
}
```

I know, I know... now I have two problems. Well... *two challenges*.

Anyway:

- the first substitution takes care of removing all consecutive slashes,
  or groups pointing to the same directory as the previous one (e.g. as
  in `/a/./b', removing the './` part);
- the second substitution removes the trailing slash, if any;
- the third substitution removes all the *up a directory* parts.

Seems to be working:

```shell
$ perl perl/ch-1.pl 
ok 1 - /a/
ok 2 - /a//b/c/
ok 3 - /a/b/c/../..
ok 4 - /a/b/c/../../
ok 5 - /a/./b/.//./c/../../
ok 6 - /a/../../../b/
1..6
```

The whole program is:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use Test::More;

sub canonical_path ($p) {
   $p =~ s{/\K(?:\.?/)+}{}gmxs;
   $p =~ s{\A/.*\K/\z}{}mxs;
   1 while $p =~ s{/[^/]+/\.\.(/|\z)}{$1}mxs;
   return $p;
}

for my $test(
   [qw< /a/ /a >],
   [qw< /a//b/c/ /a/b/c >],
   [qw< /a/b/c/../.. /a >],
   [qw< /a/b/c/../../ /a >],
   [qw< /a/./b/.//./c/../../ /a >],
   [qw< /a/../../../b/ /b >],
) {
   my ($input, $expected) = $test->@*;
   my $got = canonical_path($input);
   is $got, $expected, $input;
}

done_testing;
```

Stay safe folks!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#112]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-112/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-112/#TASK1
[Perl]: https://www.perl.org/
