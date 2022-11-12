---
title: skfold - repeated files
type: post
tags: [ skfold, perl, coding ]
series: skfold
comment: true
date: 2020-06-23 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [skfold][] supports repeating a template programmatically.

One problem I had to face with [skfold][] was with kickstarting a
[Perl][] distro with a few modules, each in its own separate file.

There are two issues here:

- I don't know how many of them will be
- I don't know what their file names should be

This is where [skfold][] asks for help! It looks for a `custom.pm` file
in the specific module's directory, loads it (as a [Perl][] module) and
uses it to do this module-specific translation. Let's look at an
example.

# Turning packages into filenames

The function that is supposed to do the magic is
`adapt_module_configuration`. It is supposed to transform the loaded
configuration according to the specifics of the situation, in this case
*expanding* the `files` section of the configuration itself with the
right files in the right places.

```perl
 1 sub adapt_module_configuration {
 2    my ($config) = @_;
 3    $config->{whatevah} = 1;
 4    my $tdir = path($config->{target_dir});
 5    $config->{target_dir} =~ s{::}{-}gmxs;
 6 
 7    my (%directories, %modules);
 8    for my $module ($config->{target}, @{$config->{args}}) {
 9       next if exists $modules{$module};
10       (my $path = "lib/$module.pm") =~ s{::}{/}gmxs;
11       my $dir = path($path)->parent;
12       while ($dir ne '.') {
13          $directories{$dir} = 1;
14          $dir = $dir->parent;
15       }
16       $modules{$path} = $module;
17    }
18 
19    my @files = map {
20       if ($_->{destination} eq '*') {
21          my %model = %$_;
22          (
23             map({
24                {
25                   destination => $_,
26                   mode => $model{dmode},
27                }
28             } sort { length $a <=> length $b } keys %directories),
29             map({
30                {
31                   %model,
32                   destination => $_,
33                   opts => {
34                      %{$model{opts} || {}},
35                      module => $modules{$_},
36                      filename => $_,
37                   },
38                }
39             } keys %modules)
40          );
41       }
42       else {
43          $_
44       };
45    } @{$config->{files}};
46 
47    $config->{files} = \@files;
48 };
```

This is probably more complicated than it should... but bear with me.

Lines 4 and 5 adapt the name of the target directory. Here, a target of
`My::Module` is transformed into the typical `My-Module`.

In lines 7 to 17 we prepare our list of directories and files to be
created. For the files is easy: we assume that the `target` and all
`args` remaining after parsing are module names, which allows us to call
[skfold][] like this:

```shell
$ skf My::Module perl-distro My::Module::Util My::Module::Base
#     ^^^^^^^^^^ ^^^^^^^^^^^ ^^^^^^^^^^^^^^^^ ^^^^^^^^^^^^^^^^
#     |          |           |                |
#     |          |           |                additional Perl module
#     |          |           addiitonal Perl module
#     |          skfold module name
#     target (also a Perl module)
```

Perl module names are turned into a path inside the `lib` sub-directory
(line 10), and all the directories are collected to create them on the
way. So, after line 17, we know all the files and directories that will
have to be created.

The loop in lines 19 through 45 expands the `files` section of the
input configuratio, looking for one whose destination is `*` (this is
totally a convention for this [skfold][] module!). Everything else goes
through unmodified (line 43), but this `*` entry is used to generate
entries for directories first (lines 23 to 28) and then files (lines 29
to 39), making sure to use the right file creation mode.

Line 47, at last, fixes this expanded list in the configuration, so that
[skfold][] will operate on it. Done!

The full example can be seen here: [skfold module for perl-distro][].

# Chhers!

Time to wrap up: [skfold][] can indeed generate a complicated hierarchy
of files, with a little help from the module designer.


[skfold]: https://github.com/polettix/skfold
[Perl]: https://www.perl.org/
[skfold module for perl-distro]: https://github.com/polettix/skfold/blob/master/dot-skfold/modules/perl-distro/custom.pm
