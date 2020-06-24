---
title: 'Today I Learned: fatpack and PERL5LIB'
type: post
tags: [ skfold, fatpacker, Perl ]
comment: true
date: 2020-06-25 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Today I Learned that [fatpack][] relies on absolute paths in
> `PERL5LIB`.

While attempting to [fatpack][] the main program for [skfold][]:

```shell
$ local/bin/fatpack pack bin/skf > skf
```

I got out a file without the embedded [Perl][] modules. How come?!?

# Due preliminary note

As you may have noticed, I installed [fatpack][] inside `local`, along
with the supporting modules for [skfold][]. To make sure that the
modules there are found, I set this:

```shell
$ export PERL5LIB='local/lib/perl5'
```

The relative path does not really bother me - I'm not planning to call
[skfold][] from any other directory than the project's root while
hacking on it.

# So let's troubleshoot this

The command I called was the all-in-one, so I thought it best to break
it down into the different components.

It turns out that there are four stages:

- `trace`: some magic figures out which modules are needed by our
  program and produces a list of their associated module files;
- `packlists-for`: from a list of module files, a list of the files
  included in the package each was installed for is produced (these
  files are installed as `packlist`, this is why the command is called
  `packlists-for`);
- `tree`: from a list of `.packlist` files, produce a sub-directory
  `fatlib` with all the associated files (including, as it seems, POD
  files);
- `file`: from a file, a `lib` and a `fatlib`, produce the final
  fat-packed artifact.

Let's start!

## Trace

While the other sub-commands seem to work fine with the standard file
descriptors (standard input and standard output), the initial tracing
command defaults to producing a `yadda-yadda-yadda.trace` file, that we
will eventually need to `cat` anyway. Luckily, there's an option to send
it to the standard output right away:

```shell
$ local/bin/fatpack trace --to=- bin/skf
...
Path/Tiny.pm
...
Template/Perlish.pm
...
Log/Log4perl/Tiny.pm
...
```

The list seems fine to me, and the target modules that are not part of
CORE are there, so let's move on.

## Packlist files

The next step is producing the list of `.packlist` files:

```shell
$ local/bin/fatpack packlists-for \
    $(local/bin/fatpack trace --to=- bin/skf)
bin/skf syntax OK
/home/foo/skfold/local/lib/perl5/x86_64-linux-gnu-thread-multi/auto/Log/Log4perl/Tiny/.packlist
/home/foo/skfold/local/lib/perl5/x86_64-linux-gnu-thread-multi/auto/Path/Tiny/.packlist
/home/foo/skfold/local/lib/perl5/x86_64-linux-gnu-thread-multi/auto/Template/Perlish/.packlist
```

Again, it seems encouraging because it detected exactly the right
modules that we need to include in our *fat-packed* version. Let's move
on!

## Tree

Let's call the `tree` sub-command now:

```shell
$ local/bin/fatpack tree $(local/bin/fatpack packlists-for \
    $(local/bin/fatpack trace --to=- bin/skf))
bin/skf syntax OK

$ find fatlib
fatlib
```

Ouch! Files are not copied to the `fatlib` sub-directory, here's why
they don't appear in the overall file.

A quick look at the code is helpful (from [here][app-fatpack-tree]):

```perl
 1 sub packlists_to_tree {
 2   my ($self, $where, $packlists) = @_;
 3   rmtree $where;
 4   mkpath $where;
 5   foreach my $pl (@$packlists) {
 6     my ($vol, $dirs, $file) = splitpath $pl;
 7     my @dir_parts = splitdir $dirs;
 8     my $pack_base;
 9     PART: foreach my $p (0 .. $#dir_parts) {
10       if ($dir_parts[$p] eq 'auto') {
11         # $p-2 normally since it's <wanted path>/$Config{archname}/auto but
12         # if the last bit is a number it's $Config{archname}/$version/auto
13         # so use $p-3 in that case
14         my $version_lib = 0+!!($dir_parts[$p-1] =~ /^[0-9.]+$/);
15         $pack_base = catpath $vol, catdir @dir_parts[0..$p-(2+$version_lib)];
16         last PART;
17       }
18     }
19     die "Couldn't figure out base path of packlist ${pl}" unless $pack_base;
20     foreach my $source (lines_of $pl) {
21       # there is presumably a better way to do "is this under this base?"
22       # but if so, it's not obvious to me in File::Spec
23       next unless substr($source,0,length $pack_base) eq $pack_base;
24       my $target = rel2abs( abs2rel($source, $pack_base), $where );
25       my $target_dir = catpath((splitpath $target)[0,1]);
26       mkpath $target_dir;
27       copy $source => $target;
28     }
29   }
30 }
```

The *culprit* is in line 23, excused by the comment in lines 21 and 22.

Setting `PERL5LIB` to a relative path makes variable `$pack_base`
(declared in line 8, populated in line 15) hold a relative path too,
like (in our case) `local/lib/perl5`.

On the other hand, paths inside the `.packlist` files are listed with
absolute paths:

```shell
$ cat local/lib/perl5/x86_64-linux-gnu-thread-multi/auto/Path/Tiny/.packlist 
/home/foo/skfold/local/lib/perl5/Path/Tiny.pm
```

For this reason, the comparison in line 23 is going to put an absolute
portion of a path on the left hand side (i.e. the output of the
`substr` call) and a relative path on the right hand side.

Setting `PERL5LIB` to an absolute value solves the problem:

```shell
$ export PERL5LIB="$PWD/local/lib/perl5"
$ local/bin/fatpack tree $(local/bin/fatpack packlists-for \
    $(local/bin/fatpack trace --to=- bin/skf))
bin/skf syntax OK

$ find fatlib/
fatlib/
fatlib/Path
fatlib/Path/Tiny.pm
fatlib/Log
fatlib/Log/Log4perl
fatlib/Log/Log4perl/Tiny.pm
fatlib/Log/Log4perl/Tiny.pod
fatlib/Template
fatlib/Template/Perlish.pm
fatlib/Template/Perlish.pod
```

# Conclusion

Needless to say... I'll put items in `PERL5LIB` as absolute paths from
now on!

[app-fatpack-tree]: http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=p5sagit/App-FatPacker.git;a=blob;f=lib/App/FatPacker.pm;h=e376e6f4244fac9a1e04e7c330f0f97c832b4fb4;hb=d1f34abed80b8760b5d6441168997b5fd1f72251#l176
[fatpack]: https://metacpan.org/release/App-FatPacker
[skfold]: https://github.com/polettix/skfold
[Perl]: https://www.perl.org/
