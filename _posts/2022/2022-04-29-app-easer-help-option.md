---
title: 'App::Easer help as (command line) option'
type: post
tags: [ perl, terminal ]
comment: true
date: 2022-04-29 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [App::Easer][] V2 now can output the `help` even for non-hierarchical
> applications.

To get `help` about a command, `App::Easer::V2` provides a `help`
sub-command out of the box *most of the times*. The exception is for
*leaf* commands, which do not have sub-commands.

This is not a big deal with hierarchical applications, because it's
possible to invoke the `help` sub-command of the parent command and pass
the name of the sub-command we need help with:

```
# print help about `topcmd`
$ topcmd help

# print help about `subcmd` under `topcmd`
$ topcmd help subcmd
```

On the other hand, for non-hierarchical applications, the only available
command is also a leaf and this hinders getting a meaningful,
auto-generated help text off the shelf.

In this case, it's possible to include an option for getting help, like
this:

```perl
my $app = {
   options => [
      {
         getopt => 'help|h!',
         help   => 'print help on the command',
      },
      ...
```

Then, inside the `execute` sub, it's possible to *run* the *help*
sub-command explicitly:

```perl
sub execute ($self) {
   return $self->run_help if $self->config('help');

   # ... normal code for "execute"
   # ...
}
```

In addition, it's also possible to get the *text* of the full help, e.g.
if it needs some additional formatting before being printed out. In the
example below this is indented with some spaces before being printed out
between two markers:

```perl
sub execute ($self) {
   if ($self->config('help')) {
      say '--- this is some wrapping for the help ---';
      print $self->full_help_text =~ s{^}{     }rgmxs;
      say '--- end of the help here, and of wrapping too ---';
      return 0;
   }

   # ... normal code for "execute"
   # ...
}
```

Thanks to [djerius][] for [pointing out this need][]!

Now I'll have to bite the bullet and finally release V2...

[Perl]: https://www.perl.org/
[djerius]: https://github.com/djerius
[App::Easer]: https://metacpan.org/pod/App::Easer
[pointing out this need]: https://github.com/polettix/App-Easer/issues/2
