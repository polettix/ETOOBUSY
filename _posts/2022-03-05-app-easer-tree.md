---
title: 'App::Easer - tree auto-command'
type: post
tags: [ perl, client, terminal ]
comment: true
date: 2022-03-05 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I added a command `tree` to the stock automatic commands `help` and
> `commands`.

I used [App::Easer][] V2 a lot lately (which reminds my I have to
release it!) and the octopus root command is gaining mass. To the point
that *sometimes* I wonder where a sub-command lives actually, or even if
I already implemented it.

After looking in the source tree one time too many, I decided to add a
`tree` sub-command to the automatically available ones, i.e. `help` and
`commands`.

I'm happy with [the implementation][tree], in particular because it
leverages the implementation of `commands` by changing one of its
functions (and providing the right metadata):

```perl
package App::Easer::V2::Command::Tree;
push our @ISA, 'App::Easer::V2::Command::Commands';
sub aliases     { 'tree' }
sub description { 'Print tree of supported sub-commands' }
sub help        { 'print sub-commands in a tree' }
sub name        { 'tree' }

sub options {
   return (
      {
         getopt      => 'include_auto|include-auto|I!',
         default     => 0,
         environment => 1,
      },
   );
} ## end sub options

sub list_commands ($self, $target) {
   my $exclude_auto = $self->config('include_auto') ? 0 : 1;
   my @lines;
   for my $command ($target->inflate_children($target->list_children)) {
      my ($name) = $command->aliases or next;
      next
        if $name =~ m{\A(?: help | commands | tree)\z}mxs && $exclude_auto;
      my $help = $command->help // '(**missing help**)';
      push @lines, sprintf '- %s (%s)', $name, $help;
      if (defined(my $subtree = $self->list_commands($command))) {
         push @lines, $subtree =~ s{^}{  }rgmxs;
      }
   } ## end for my $command ($target...)
   return unless @lines;
   return join "\n", @lines;
} ## end sub list_commands
```

And now... let's get back to writing tests...


[Perl]: https://www.perl.org/
[tree]: https://github.com/polettix/App-Easer/blob/930cae9ab70134e1bd762488ddafd57e25968ed9/lib/App/Easer/V2.pm#L805
[App::Easer]: https://github.com/polettix/App-Easer
