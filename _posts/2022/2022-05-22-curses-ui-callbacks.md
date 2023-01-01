---
title: 'Curses::UI callbacks'
type: post
tags: [ perl, curses, terminal ]
comment: true
date: 2022-05-22 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> One additional note about [Curses::UI][].

In previous post [Curses::UI and signatures][] we saw that callback
functions might be called with a variable number of parameters depending
on where they kick in, so we are bound to be careful in doing this -
expecially if we're using *signatures*.

It turns out that the very *first* parameter might vary too, depending
on that. In the following example, the `exit_dialog` callback function
doubles down to be called via *CTRL-Q* and using the `Quit` menu entry:

```perl
#!/usr/bin/perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use Curses::UI;

my $cui = new Curses::UI(-color_support => 1);

my $menu = $cui->add(
   menu  => 'Menubar',
   -menu => [
      {
         -label   => 'File',
         -submenu => [{-label => 'Quit', -value => \&exit_dialog}],
      }
   ],
);

my $win = $cui->add(win  => 'Window',     -padtop => 1);
my $ted = $win->add(text => 'TextEditor', -text   => 'Ahoy!');

$cui->set_binding(sub { $menu->focus }, "\cX");
$cui->set_binding(\&exit_dialog, "\cQ");
$ted->focus;

$cui->mainloop;

sub exit_dialog ($c, @rest) {
   $c = $c->parent unless $c->can('dialog');
   exit 0
     if $c->dialog(
      -message => "Do you really want to quit?",
      -title   => "Are you sure???",
      -buttons => ['yes', 'no'],

     );
} ## end sub exit_dialog
```

When called from the menu, we can get back to the `$cui` object calling
the `parent()` method; the way we test it is with `can('dialog')`,
because a menu `can`'t.

Stay safe everybody!


[Curses::UI and signatures]: {{ '/2022/05/21/curses-ui-and-signatures/' | prepend: site.baseurl }}
[Perl]: https://www.perl.org/
[Curses::UI]: https://metacpan.org/pod/Curses::UI
