---
title: Counting tags in this blog
type: post
tags: [ blog, coding, perl ]
comment: true
date: 2020-05-14 07:00:00 +0200
published: true
---

**TL;DR**

> Where I need to cleanup tags in this blog.

Looking through some posts, I've been hit by the suspect that I might
need to do some cleanup in the *tags*. One example is that I've used
`command-line` and `command line` - shouldn't I use only one?

# Perl to the rescue

The following [Perl][] script helped me out:

```perl
 1 #!/usr/bin/env perl
 2 use strict;
 3 use warnings;
 4 use autodie;
 5 
 6 my %count_for;
 7 for my $filename (@ARGV) {
 8    open my $fh, '<', $filename;
 9    while (<$fh>) {
10       my ($tags) = m{\A tags: \s* \[ (.*?) \]}mxs or next;
11       for (split m{,}mxs, $tags) {
12          (my $tag = $_) =~ s{\A\s+|\s+\z}{}gmxs;
13          $count_for{$tag}++;
14       }
15       last;
16    }
17 }
18 
19 print "$_: $count_for{$_}\n" for sort {$a cmp $b} keys %count_for;
```

After some boilerplate (lines 1 to 4) we get into the real action. Let's
just note that module `autodie` helps us forget about checking the
outcome of opening files (line 8), reading them, or closing them (which
does not even appear here, but is performed by [Perl][] behind the
scenes).

The strategy is straightforward: first let's go through all the input
files, counting the occurrence of all *tags* (lines 6 to 17), then print
out these counts sorting the tags lexicographically (line 19), so that
we can easily spot similar *tags* with different spellings.

The first loop (line 7) iterates over all input files; this means that
our script should be called like this:

```shell
$ perl count-tags.pl _posts/*.md
# ...
```

Each file is opened (line 8) and read line by line, until we hit the
line with the *tags* (which means that we get past line 10). These tags
are collected in variable `$tags`, which we split by commas iterating
over the results (line 11), each of which is first trimmed (line 12) and
then used to increment the corresponding count in hash `%count_for`
(line 13).

Printing is easy: we iterate over the sorted keys of hash `%count_for`,
and print the key and the corresponding count, one per line (all in line
19).

# Does it work?

I daresay... yes, I spotted the following candidates for some cleanup:

```
command line: 2
command-line: 1
...
math: 1
maths: 19
...
print and play: 1
print-and-play: 1
```

Looking at the other tags, I think I'll stick to the *space-separated*
alternatives!

# Interested?

The code can be easily copied from this blog post, or downloaded from a
[local version][]. Enjoy!

[Perl]: https://www.perl.org/
[local version]: {{ '/assets/code/count-tags.pl' | prepend: site.baseurl }}
