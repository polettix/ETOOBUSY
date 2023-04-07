---
title: PWC203 - Copy Directory
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-02-10 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#203][].
> Enjoy!

# The challenge

> You are given path to two folders, `$source` and `$target`.
>
> Write a script that recursively copy the directory from `$source` to
> `$target` except any files.
>
> **Example**
>
>     Input: $source = '/a/b/c' and $target = '/x/y'
>
>     Source directory structure:
>
>     ├── a
>     │   └── b
>     │       └── c
>     │           ├── 1
>     │           │   └── 1.txt
>     │           ├── 2
>     │           │   └── 2.txt
>     │           ├── 3
>     │           │   └── 3.txt
>     │           ├── 4
>     │           └── 5
>     │               └── 5.txt
>
>     Target directory structure:
>
>     ├── x
>     │   └── y
>
>     Expected Result:
>
>     ├── x
>     │   └── y
>     |       ├── 1
>     │       ├── 2
>     │       ├── 3
>     │       ├── 4
>     │       └── 5

# The questions

Uh... messing up with the filesystem is *wicked* without proper
requirements! Like...

- ... what happens if some items are *already there*
- ... what permissions should be set on the newly created directories?
- ... should we try to set ownership too?

# The solution

I decided to go for CORE stuff... so there's some work to do:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use English '-no_match_vars';
use experimental 'signatures';
no warnings 'experimental::signatures';

use File::Spec::Functions qw< splitpath splitdir catdir catpath >;
use File::Path qw< make_path >;

copy_directory(@ARGV);

sub copy_directory ($from, $to) {
   my ($fv, $fds) = splitpath($from, 'no-file');
   my ($tv, $tds) = splitpath($to, 'no-file');
   opendir my $dh, $from or die "opendir('$from'): $OS_ERROR";
   for my $item (readdir($dh)) {
      next if ($item eq '.') || ($item eq '..');
      my $source = catpath($fv, $fds, $item);
      next unless -d $source;
      my (undef, undef, $mode) = stat($source);
      my $target = catpath($tv, $tds, $item);
      make_path($target, {mode => $mode});
      __SUB__->($source, $target);
   }
}
```

[Raku][] allows for some more idiomatic stuff:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN ($from, $to) { copy-directory($from, $to) }

sub copy-directory (IO::Path() $from, IO::Path() $to) {
   for $from.dir -> $source {
      next unless $source.d;
      my $target = $to.child($source.basename).mkdir($source.mode);
      samewith($source, $target);
   }
}
```

Aaaaaaaaand... *that's all folks!*

[The Weekly Challenge]: https://theweeklychallenge.org/
[#203]: https://theweeklychallenge.org/blog/perl-weekly-challenge-203/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-203/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
