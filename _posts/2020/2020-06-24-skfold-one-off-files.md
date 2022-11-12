---
title: skfold - one-off files
type: post
tags: [ skfold, perl, coding ]
series: skfold
comment: true
date: 2020-06-24 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [skfold][] supports generating one-off files in addition to more
> structured directories.

One of the issues I planned to address with [skfold][] was generating
kick-start files for [dibs][].

To some extent, this is somehow the *contrary* of what we saw up to now:

- generation of a single file instead of a new, stand-alone directory
- choice of one single template out of - possibly - many similar ones.

The second bullet can be easily addressed by having separate modules for
each [dibs][] template, but leveraging a single one was *really* simple
and actually didn't require any specific support/change in [skfold][],
so why not?

# The dibs module

The [dibs module for skfold][skfold-dibs] is available on GitHub, let's
take a quick look.

## Templates

There are two templates, at least as of now. One is for a full-fledged
[Perl][] application, with its own base images for fine control over
caching; the other one is to build quick applications, possibly just
based on a few system packages.

As in the rest of [skfold][], these are actually [Template::Perlish][]
templates.

## Configuration file

The [configuration file for the dibs module][skfold-dibs-config] has a
few options that can be provided on the command line (or set in the main
`defaults.json` file for [skfold][]. Nothing really fancy here, except
maybe option `templates|T` that is marked as being `meta`. This means
that, when present, this option overrides the regular check on mandatory
variables, because this option will actually be used to generate a list
of template files that are available through this module, hence the
other options are not really needed.

Another peculiarity is the option `single-file`, set at the top level.
This indicates to [skfold][] that we don't expect to have a directory
generated in this case, just a single file. Additionally, this also
means that this generated file might be specified as going to `-`, which
means that it will be printed on the *standard output*.

Last, the `files` section is in this case only used to set the mode. The
source template will be chosen differently (we will look at it shortly)
and the destination file is, of course, to be determined dynamically.

## Customization

The customization [Perl][] module includes the following extension
function `adapt_module_configuration` (see also [skfold - repeated
files][]).

```perl
 1  sub adapt_module_configuration {
 2     my ($config) = @_;
 3
 4     return _templates_list($config) if $config->{opts}{templates};
 5
 6     my $source = $config->{opts}{template};
 7     main::LOGDIE "select one template with -t (call with -T for list)"
 8        unless defined $source;
 9
10     my $spec = $config->{files}[0];
11     my ($target, @files);
12     if ($config->{target} eq '-') {
13        $target = '-';
14     }
15     else {
16        $target = path($config->{target})->absolute;
17        @files = map {
18           my %record = (destination => $_);
19           $record{mode} = $spec->{dmode} if defined $spec->{dmode};
20           \%record;
21        } ancestors_for($target);
22     }
23     push @files, { %$spec, destination => $target, source => $source };
24     $config->{files} = \@files;
25
26     $config->{target_dir} = path('/');
27
28     return;
29  };
```

As anticipated, the whole logic of selecting one single template has
been moved into the customization module (line 6 gets the actual source
to use from the command line, then line 23 sets this template as the
source that will be used by [skfold][]). This is good because it does
not need to require any specific support from [skfold][] and somehow
makes me confident that it's already providing what's needed at the base
level.

[skfold]: https://github.com/polettix/skfold
[Perl]: https://www.perl.org/
[skfold module for perl-distro]: https://github.com/polettix/skfold/blob/master/dot-skfold/modules/perl-distro/custom.pm
[dibs]: http://blog.polettix.it/hi-from-dibs/
[skfold-dibs]: https://github.com/polettix/skfold/tree/master/dot-skfold/modules/dibs
[Template::Perlish]: https://metacpan.org/pod/Template::Perlish#Templates
[skfold-dibs-config]: https://github.com/polettix/skfold/blob/master/dot-skfold/modules/dibs/config.json
[skfold - getting started with simple files]: {{ '/2020/06/22/skfold-simple-files' | prepend: site.baseurl }}
[skfold - repeated files]: {{ '/2020/06/23/skfold-repeated-files' | prepend: site.baseurl }}
