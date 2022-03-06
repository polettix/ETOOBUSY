---
title: 'App::Easer - auto-commands reflection'
type: post
tags: [ perl, client, terminal ]
comment: true
date: 2022-03-06 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I added some **reflection** to get hold of instances for handling
> auto-commands `help`, `commands`, and `tree`.

While [porting a test][test-commit] for [App::Easer][] V2, I found out
that there was an undocumented feature in V1 that allowed to get hold of
the `help` and `commands` sub-commands, e.g. to support command-line
options like `--help` and `--commands` (e.g. `--help` might be useful
for leaf commands).

So it was natural to extend the interface to [add methods][impl-commit]
that return the related instances:

```perl
sub auto_child ($self, $name, $inflate = 0) {
   my $child = __PACKAGE__ . '::' . ucfirst(lc($name));
   ($child) = $self->inflate_children($child) if $inflate;
   return $child;
}

# ...

sub auto_commands ($self) { return $self->auto_child('commands', 1) }

sub auto_help ($self) { return $self->auto_child('help', 1) }

sub auto_tree ($self) { return $self->auto_child('tree', 1) }
```

New test onboard!

[Perl]: https://www.perl.org/
[test-commit]: https://github.com/polettix/App-Easer/commit/41228ae9b6fb5e82a7dbfcd07d03b22f6ecf60e0
[App::Easer]: https://github.com/polettix/App-Easer
[impl-commit]: https://github.com/polettix/App-Easer/commit/e97d157a4c379dda150eafcf0e4d8cdacc2710ab#diff-643c95ab56ed7b5b3219172d26549c7057b05bf5d252aeaabda14680e4cdfd83L508
