---
title: 'App::Easer and Moo'
type: post
tags: [ perl, client, terminal ]
comment: true
date: 2022-03-07 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I tried [App::Easer][] V2 and [Moo][] together, they can get along
> apparenty.

In [App::Easer][] V2 I'm relying upon bare OOP capabilities in [Perl][],
i.e. basically `bless` and `@ISA`. Making `use` of the module in the
right way takes care of setting up the hierarchy, inheriting from
`App::Easer::V2::Command`:

```perl
package MyCommand;
use App::Easer::V2 '-command';
...
```

The `-command` [does the trick][]:

```perl
sub import ($package, @args) {
   # ...
   while (@args) {
      my $request = shift @args;
      if ($request eq '-command') {
         $registered{$target} = 1;
         no strict 'refs';
         push @{$target . '::ISA'}, 'App::Easer::V2::Command';
      }
      # ...
```

I was wondering how does this play with using common approaches to a
more *modern* OOP in [Perl][], like [Moo][]. I mean,
`App::Easer::V2::Command` provides its own `new` method, so there is the
potential for a clash.

From a small experiment I run (in example [`moodu2`][]), it turns out
that they can get along if [App::Easer][] V2 is used **before** [Moo][]
(like [here][example1]):

```perl
package TuDu::Command;
use Path::Tiny 'path';
use POSIX 'strftime';
use App::Easer::V2 '-command';

use Moo;
use experimental 'signatures';
no warnings 'experimental::signatures';

BEGIN {
   has time_format => (is => 'lazy');
}

sub _build_time_format ($self) { $self->config('time_format') }

# ...
```

Example run (with some data):

```
$ ./moodu2 list
o1 [ongoing] let's do it
o2 [ongoing] Go to the visit
o3 [ongoing] Help
o4 [ongoing] this is a new task
o5 [ongoing] This is a brand new task
o6 [ongoing] This is a task
w1 [waiting] Blurb the Birbs - but better
```

Inverting them does not make the program happy any more:

```
$ ./moodu2 list
cannot find sub-command 'list'
```

I don't know the internals of [Moo][] or how the method resolution
algorithm works, I can only guess that method `new` comes from [Moo][]
and the whole thing stops working.

So... order matters.

Stay save everybody!

[Perl]: https://www.perl.org/
[moodu2]: https://github.com/polettix/App-Easer/blob/bef79417159824df1d7558e043b05b6af78ca988/eg/moodu2
[App::Easer]: https://github.com/polettix/App-Easer/
[Moo]: https://metacpan.org/pod/Moo
[does the trick]: https://github.com/polettix/App-Easer/blob/versioning/lib/App/Easer/V2.pm#L36
[example1]: https://github.com/polettix/App-Easer/blob/bef79417159824df1d7558e043b05b6af78ca988/eg/moodu2#L181
