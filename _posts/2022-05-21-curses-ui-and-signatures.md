---
title: 'Curses::UI and signatures'
type: post
tags: [ perl, curses ]
comment: true
date: 2022-05-21 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> There's some attention to take when using [Curses::UI][] with [Perl][]
> signatures.

I was looking at [Curses::UI][] and hit a problem with this *slight
adaptation* 🙄 of the stock tutorial code:

```perl
#!/usr/bin/perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use Curses::UI;

my $cui = new Curses::UI(-color_support => 1);
my $win = $cui->add(win => 'Window');
my $ted = $win->add(text => 'TextEditor', -text => 'Ahoy!');

$cui->set_binding(\&exit_dialog, "\cQ");
$ted->focus();
$cui->mainloop();

sub exit_dialog ($c) {
   exit 0
     if $c->dialog(
      -message => 'Do you really want to quit?',
      -title   => 'Are you sure???',
      -buttons => ['yes', 'no'],
     );
} ## end sub exit_dialog
```

This starts, shows stuff, lets me type things... but when I hit *CTRL-Q*
to exit it fails miserably, exiting with exit code 255 without showing
the confirmation dialog.

What gives?

The callback function `exit_dialog` called through the binding with the
key is called with *two* parameters, i.e. the object where the binding
belongs (i.e. `$cui` in our example) *and* the sequence bound to the
callback (because there might be many bound to the same callback).

The same callback might also be *reused* in a menu, in which case it
would be passed one single argument (i.e. the menu object). So if we
plan on using the same callback in multiple places, we better plan on
accepting a variable number of input parameters:


```perl
#!/usr/bin/perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use Curses::UI;

my $cui = new Curses::UI(-color_support => 1);
my $win = $cui->add(win => 'Window');
my $ted = $win->add(text => 'TextEditor', -text => 'Ahoy!');

$cui->set_binding(\&exit_dialog, "\cQ");
$ted->focus();
$cui->mainloop();

sub exit_dialog ($c, @rest) {
   exit 0
     if $c->dialog(
      -message => 'Do you really want to quit?',
      -title   => 'Are you sure???',
      -buttons => ['yes', 'no'],
     );
} ## end sub exit_dialog
```

This works, yay!


[Perl]: https://www.perl.org/
[Curses::UI]: https://metacpan.org/pod/Curses::UI
