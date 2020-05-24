---
title: 'Git::Wrapper'
type: post
tags: [ perl, git, coding ]
comment: true
date: 2020-05-28 07:00:00
mathjax: false
published: true
---

**TL;DR**

> [Git::Wrapper][] is an interesting [Perl][] module.

[Git][] is a fine piece of software that is usually driven through the
`git` command-line tool. [Git::Wrapper][] is a... wrapper around this
command, so that it's easy to interact with it from [Perl][].


# Getting started

Installing it should not give problems (see [Installing Perl Modules][]
if you want a few suggestions). As a bare minimum, the `new` method
requires a path to a directory (more on this later):

```perl
use Git::Wrapper;

my $git = Git::Wrapper->new('/path/to/somewhere');
```

It's not necessary that the provided directory is already tracked with
[Git][], because you can call `init` just as you might do on the command
line:

```perl
$git->init;
```

# Input interface

The input interface of the module is an attempt at being flexible, e.g.
passing a hash reference (that is expanded as key-value pairs, with no
specific order) or a list of parameters.

```perl
$git->commit({ message => "stuff" , all => 1 });
# produces either of the following:
#   git commit --all --message stuff
#   git commit --message stuff --all

$git->commit(qw< --message stuff --all >)
# produces
#   git commit --message stuff --all
```

There are possibly other variants. I personally find just passing a list
sufficient for the job, but your taste might be different.

# Output interface

The output interface is... basic. It provides back a list of (`chomp`ed)
lines from the command invocation output, without any attempt at parsing
it. I'm not sure about this choice, it's surely simple and probably
going for parsing each and every sub-command would be overkill.

This is an example of a possible parsing function for the output of `git
branch -av`:

```perl
 1 sub git_branch {
 2    my $git = shift;
 3    my $current;
 4    my @branches = map {
 5       my ($f, $name, $sha1, $msg) =
 6         m{\A
 7            (.) \s+   # flag
 8            ((?: \(.*?\) ) | (?:\S+)) \s+ # name
 9            (\S+) \s+ # SHA1
10            (.*)      # log message title
11         }mxs;
12       my $branch = {
13          name        => $name,
14          sha1        => $sha1,
15          message     => $msg,
16          is_current  => ($f eq '*' ? 1 : 0),
17          is_detached => (substr($name, 0, 1) eq '(' ? 1 : 0),
18       };
19       $current = $branch if $branch->{is_current};
20       $branch;
21    } $git->branch(qw< --no-color -av >);
22    return {
23       current => $current,
24       branches => \@branches,
25    };
26 } ## end sub git_branch ($git)
```

Anyway, it's not more difficult of what you would get in the shell, with
the notable exception that... you have [Perl][] in your toolbox!

One great thing is that the module throws an exception when an error
occurs, so this allows managing errors simple and consistent.
[Try::Catch][] or other similar modules can help to this regard.

# The directory

One thing that is a bit edgy is the provision of a directory path. It
generally does its job... except when it doesn't 🙄

In particular, using the `clone` sub-command can be counter-intuitive
because the clone is *not* created in the target directory. For example:

```perl
my $git = Git::Wrapper->new('./whatever');
$git->clone('https://github.com/polettix/ekeca.git');
```

The first line sets the object's directory to `whatever` in the current
directory, while the `clone` command creates a directory `ekeca` in the
current directory. After the `clone`, though, the object is *still* set
to `whatever`... like the `clone` didn't happen.

A possible workaround might be to pass the target directory for `clone`
in the command invocation itself:

```perl
my $git = Git::Wrapper->new('./whatever');
$git->clone('https://github.com/polettix/ekeca.git', $git->dir);
```

# Final thoughts

The module is indeed interesting for a little side project... and I'm
going to use it!



[Git::Wrapper]: https://metacpan.org/pod/Git::Wrapper
[Perl]: https://www.perl.org/
[Git]: https://www.git-scm.org/
[Installing Perl Modules]: {{ '/2020/01/04/installing-perl-modules' | prepend: site.baseurl }}
[Try::Catch]: https://metacpan.org/pod/Try::Catch
