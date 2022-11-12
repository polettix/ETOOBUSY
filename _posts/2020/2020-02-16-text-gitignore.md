---
title: Text::Gitignore
type: post
tags: [ perl, git ]
comment: true
date: 2020-02-16 07:25:47 +0100
published: true
---

**TL;DR**

> Somehow niche, but [Text::Gitignore][] hits the nail right in the head
> when you need that kind of functionality.

In [dibspack-basic][] (the companion to [dibs][]) I wanted to include a
utility function to copy files from a *build* phase, preparing them for the
*bundling* phase.

If you don't know what I'm talking about, a little recap: [dibs][] is a
utility to streamline producing [Docker][] images, and my process usually
takes two steps:

- in the *build* step, I work in an image where I install all tools that
  support the build process, e.g. a compiler, development versions of
  libraries, ancillary tools, etc., without worrying too much about bloat;

- in the *bundle* step, I strive to create the tightiest image possible,
  only including artifacts that are strictly necessary *at runtime*.

Communication across these two steps happens through a shared *cache*
directory where the *build* process saves compiled artifacts, and the
*bundle* process takes them to the final destination.

If I start from a distribution e.g. on GitHub, I might not want to include
everything in the distribution inside the final [Docker][] image. As an
example, the `.git` directory used by [git][] to track files is not
necessary; for [Perl][] programs, a `cpanfile`/`cpanfile.snapshot` pair of
files only makes sense at build time, not at runtime. Hence, for
[dibspack-basic][] I needed a mechanism that allowed me to *exclude*
unwanted files/directories.

I was about to code something when something hit me: there must be already
something in [CPAN][]! And sure there is: [Text::Gitignore][]. To be fair,
it's not the only one, but I tried it and was pretty happy about it, so I
didn't feel the need to evaluate anything else.

The module provides a basic but helpful function to create a *matcher*
anonymous sub, i.e. a sub that accepts a file path and tells you whether it
matches or not some patterns written according to the rules of a
`.gitignore` file. This format is particularly attractive because it's what
[git][] uses, so people should have no surprises when told to adopt the same
exact approach.

# Example usage: traversing a directory tree

When you want to use it in a filesystem tree, you have to do some coding of
your own, something like this (we're relying upon [Path::Tiny][] because
it's soooo useful):

```perl
 1| use Path::Tiny 'path';
 2| use Text::Gitignore 'build_gitignore_matcher';
 3| use constant IGNOREFILE => '.ignore';
 4| #...
 5| sub find_files {
 6|    my $root = path(shift);
 7|    my @matchers = @{shift || []};
 8| 
 9|    # if this directory has a .ignore file, load it and prepare to match
10|    # stuff
11|    my $ignore = $root->child(IGNOREFILE);
12|    if ($ignore->exists) {
13|       my $matcher = build_gitignore_matcher([$ignore->lines({chomp => 1}))];
14|       push @matchers, [$root, $matcher];
15|    }
16| 
17|    # now traverse the directory
18|    my @output;
19| CHILD:
20|    for my $child ($root->children) {
21| 
22|       # skip if matched by any matcher, either in the current $root
23|       # directory or any applicable parent traversed so far
24|       for my $pair (@matchers) {
25|          my ($matcher_root, $matcher) = @$pair;
26|          my $relative_path = $child->relative($matcher_root);
27|          next CHILD if $matcher->($relative_path);
28|       }
29|       push @output, $child;
30| 
31|       # recurse, if it's a directory
32|       push @output, find_files($child) if $child->is_dir;
33|    } ## end CHILD: for my $child ($root->children)
34|    return @output;
35| } ## end sub find_files
```

This recursive function takes care to load all `.ignore` files it finds in
the tree (or whatever you put in constant `IGNOREFILE`, anyway), sticking to
the [git][] convention of honoring all `.gitignore` files in the project
tree, even those in sub-directories.

For this reason, at each directory it has a list of `@matchers` (line 7)
inherited from previous ancestor directories, which will take care of
checking files on the way. This list is enlarged only when possible, i.e.
when a `.ignore` file is present (lines 11-15).

The list of children in the directory is scanned (line 20), first checking
for possible skips (lines 24-28). In this phase, all matchers are analyzed,
although the path they are passed must be adjusted to the root path they
were created in the first place (line 26).

If the file is allowed to pass, it's added to `@output` (line 29) and, if a
directory, the whole process is recursed within it (line 32).

One caveat about `build_gitignore_matcher`: if you want to pass a *list* of
lines, pass it as a reference to an array. Otherwise, only the first will be
considered, for a good 10 minutes of confusion and puzzling!


# What *might* be missing

The behavior show in the previous section is not 100% the same as what you
would have in a `.gitignore` file. Consider the following situation:

```text
.gitignore          --> [cia*]
ciao
subdir1/ciao
subdir2/.gitignore  --> [!ciao]
subdir2/ciao
```

In this case, the top-level `.gitignore` would make [git][] ignore all
`ciao` files. Except that `subdir2/.gitignore` explicitly instructs [git][]
to **not** ignore the `ciao` file there. So, by [git][] standard, the output
list would be the following:

```text
.gitignore
subdir2/.gitignore
subdir2/ciao
```

but our program would happily ignore the `subdir2/ciao` file.

This seems unavoidable at this point: the *matcher* function currently only
tells whether something should be *excluded*, not if it should be *included*
instead. In other terms, it should return one of three values: *exclude*,
*indifferent*, and *include*; in the *indifferent* case, parent values would
apply.

Maybe a patch is due... Let me know your thinking!


[Text::Gitignore]: https://metacpan.org/pod/Text::Gitignore
[dibspack-basic]: https://github.com/polettix/dibspack-basic
[dibs]: https://github.com/polettix/dibs
[Docker]: https://www.docker.com
[CPAN]: https://metacpan.org/
[git]: https://git-scm.com/
[Path::Tiny]: https://metacpan/pod/Path::Tiny
[Perl]: https://www.perl.org/
