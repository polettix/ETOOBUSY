---
title: PWC095 - Demo Stack
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-01-14 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#095][].
> Enjoy!

# The challenge

> Write a script to demonstrate `Stack` operations like below:
>
> - `push($n)` - add `$n` to the stack
> - `pop()` - remove the top element
> - `top()` - get the top element
> - `min()` - return the minimum element

# The questions

I have to admit that this challenge... puzzled me. I mean, it's... *wide
open*.

What does it mean *demonstrate*? I take it as... both showcase some of
the functionalities (much in the spirit of the `SYNOPSIS` section in
good [Perl][] documentation) and possibly allow the user to play with
it.

Then, from a more *academic* point of view... why is `min()` an
operation over `Stack` at all? I remember `is_empty`, `push`, `pop`, and
`top`... right? The [`Stack` class][] of the [Algorithms, 4th edition][]
seems to go in the same direction (even though it exposes a few extra
methods, most notably the `size` method).

Putting `min()` means that we only accept numbers in our `Stack`? Is
this a more generic function?

I can only guess this is an interview challenge that leaves so many open
things... to see where the poor interviewed goes!

# The solution

As we're requested to do some... demonstration, we'll go on step by
step.

## The basic `Stack` class

I decided to go minimalistic, so the `Stack` class in [Perl][] is the
following:

{% raw %}
```perl
package Stack;
use 5.024;
use experimental qw< postderef signatures >;
use List::Util ();
use overload qq{""} => \&to_string;
sub is_empty ($s)  { !($s->@*) }
sub max ($s)       { $s->@* ? List::Util::max($s->@*) : die "empty\n" }
sub min ($s)       { $s->@* ? List::Util::min($s->@*) : die "empty\n" }
sub new ($package) { bless [], $package }
sub pop ($s)       { $s->@* ? CORE::pop $s->@* : die "empty\n" }
sub push ($s, $e)  { CORE::push $s->@*, $e }
sub size ($s)      { scalar $s->@* }
sub top ($s)       { $s->@* ? $s->[-1] : die "empty\n" }
sub to_string ($s, @rest) {
   return '' unless $s->@*;
   my ($min, $max, $is_top, @lines) = ($s->min, $s->max, 1);
   for my $e (reverse $s->@*) {
      CORE::push @lines, sprintf '{%5s}', $e;
      my @features;
      CORE::push @features, 'top' if $is_top;
      CORE::push @features, 'min' if $e == $min;
      CORE::push @features, 'max' if $e == $max;
      $lines[-1] .= ' (' . join(', ', @features) . ')' if @features;
      $is_top = 0;
   }
   return join "\n", @lines;
}
1;
```
{% endraw %}

The most complicated part is... to print it, as it often happens 😂 To
be honest, I've been a bit doubtful to move the stringification
*outside* of the class, in some tightly bound class suitable for
introspetion, but at the end of the day breaking the encapsulation taboo
is hard even in these *sandbox* contexts. Moreover... it allowed me to
refresh the use of [overload][] 🤓

For good measure, I added a `max()` method because... there's a `min`.
It's totally arbitrary, but still.

## A `VerboseStack` wrapper

This challenge is about a demonstration, right? So I thought to code a
little wrapper around the `Stack` class, to be *verbose* about what's
happening:

```perl
package VerboseStack;
use 5.024;
use experimental qw< postderef signatures >;
sub AUTOLOAD ($self, @as) {
   my ($stack, $echo) = $self->@{qw< stack echo >};
   (my $mname = our $AUTOLOAD) =~ s{\A.*::}{}mxs;
   say "\n$mname @as" if $echo;
   my $method = $stack->can($mname) or die "no method '$mname'\n";
   my @r = wantarray ? $stack->$method(@as) : scalar $stack->$method(@as);
   $self->print;
   return wantarray ? @r : defined(wantarray) ? $r[0] : ();
}
sub DESTROY {}
sub echo ($s) { $s->{echo} = 1 }
sub new ($pk, @as) { bless {echo => 1, @as, stack => Stack->new}, $pk }
sub noecho ($s) { $s->{echo} = 0 }
sub print ($self) {
   my $stack = $self->{stack};
   my ($n, $dump, $siz_ind) = ($stack->size, '', 'empty');
   ($dump, $siz_ind) = ("$stack\n", $n == 1 ? '1 item' : "$n items") if $n;
   print {*STDOUT} "---\n$dump------- ($siz_ind)\n";
}
sub stack ($self) { return $self->{stack} }
1;
```

It provides a few methods of its own, e.g. to turn command echoing on or
off, or to print out the current situation.

Additionally, it *delegates* to the wrapped `Stack` instance all other
method invocations, so that you can treat a `VerboseStack` just like a
`Stack` and call `push`, `top`, ...

## The provided example

At this point, we can play with the example provided in the challenge
itself:

```
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
$|++;

my $stack = VerboseStack->new;
$stack->print;

# run with --interactive to have... an interactive session
if (@ARGV && $ARGV[0] eq '--interactive') { ... }
else {
   $stack->push(2);
   $stack->push(-1);
   $stack->push(0);
   $stack->pop;       # removes 0
   say 'top returns --> ', $stack->top; # prints -1
   $stack->push(0);
   say 'min returns --> ', $stack->min; # prints -1
}
```

Let's run it:

```
$ perl perl/ch-2.pl
---
------- (empty)

push 2
---
{    2} (top, min, max)
------- (1 item)

push -1
---
{   -1} (top, min)
{    2} (max)
------- (2 items)

push 0
---
{    0} (top)
{   -1} (min)
{    2} (max)
------- (3 items)

pop 
---
{   -1} (top, min)
{    2} (max)
------- (2 items)

top 
---
{   -1} (top, min)
{    2} (max)
------- (2 items)
top returns --> -1

push 0
---
{    0} (top)
{   -1} (min)
{    2} (max)
------- (3 items)

min 
---
{    0} (top)
{   -1} (min)
{    2} (max)
------- (3 items)
min returns --> -1
```

It seems to be working!

## An interactive program

As anticipated, *demonstrate* often means *giving the possibility to
play with the thing*. So... I decided to do this as well, passing
command-line option `--interactive`:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
$|++;

my $stack = VerboseStack->new;
$stack->print;

# run with --interactive to have... an interactive session
if (@ARGV && $ARGV[0] eq '--interactive') {
   my $real_stack = $stack->stack;
   my $prompt = "\ncommand> ";
   print {*STDOUT} $prompt;
   while (<STDIN>) {
      my ($cmd, @args) = split m{\s+}mxs;
      $cmd = lc($cmd);
      last if grep { $_ eq $cmd } qw< quit exit bye >;
      eval {
         my $v = $real_stack->$cmd(@args);
         say "$cmd: $v" if grep { $_ eq $cmd } qw< max min pop top >;
         1;
      } or do {
         say $@ =~ m{\s at \s}mxs ? "unknown command $cmd" : "error: $@";
      };
      $stack->print;
      print {*STDOUT} $prompt;
   }
}
else { ... }
```

A sample session:

<script id="asciicast-383893" src="https://asciinema.org/a/383893.js" async></script>

## The whole thing...

... should you be interested into it:

{% raw %}
```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
$|++;

my $stack = VerboseStack->new;
$stack->print;

# run with --interactive to have... an interactive session
if (@ARGV && $ARGV[0] eq '--interactive') {
   my $real_stack = $stack->stack;
   my $prompt = "\ncommand> ";
   print {*STDOUT} $prompt;
   while (<STDIN>) {
      my ($cmd, @args) = split m{\s+}mxs;
      $cmd = lc($cmd);
      last if grep { $_ eq $cmd } qw< quit exit bye >;
      eval {
         my $v = $real_stack->$cmd(@args);
         say "$cmd: $v" if grep { $_ eq $cmd } qw< max min pop top >;
         1;
      } or do {
         say $@ =~ m{\s at \s}mxs ? "unknown command $cmd" : "error: $@";
      };
      $stack->print;
      print {*STDOUT} $prompt;
   }
}
else {
   $stack->push(2);
   $stack->push(-1);
   $stack->push(0);
   $stack->pop;       # removes 0
   say 'top returns --> ', $stack->top; # prints -1
   $stack->push(0);
   say 'min returns --> ', $stack->min; # prints -1
}

package VerboseStack;
use 5.024;
use experimental qw< postderef signatures >;
sub AUTOLOAD ($self, @as) {
   my ($stack, $echo) = $self->@{qw< stack echo >};
   (my $mname = our $AUTOLOAD) =~ s{\A.*::}{}mxs;
   say "\n$mname @as" if $echo;
   my $method = $stack->can($mname) or die "no method '$mname'\n";
   my @r = wantarray ? $stack->$method(@as) : scalar $stack->$method(@as);
   $self->print;
   return wantarray ? @r : defined(wantarray) ? $r[0] : ();
}
sub DESTROY {}
sub echo ($s) { $s->{echo} = 1 }
sub new ($pk, @as) { bless {echo => 1, @as, stack => Stack->new}, $pk }
sub noecho ($s) { $s->{echo} = 0 }
sub print ($self) {
   my $stack = $self->{stack};
   my ($n, $dump, $siz_ind) = ($stack->size, '', 'empty');
   ($dump, $siz_ind) = ("$stack\n", $n == 1 ? '1 item' : "$n items") if $n;
   print {*STDOUT} "---\n$dump------- ($siz_ind)\n";
}
sub stack ($self) { return $self->{stack} }
1;

package Stack;
use 5.024;
use experimental qw< postderef signatures >;
use List::Util ();
use overload qq{""} => \&to_string;
sub is_empty ($s)  { !($s->@*) }
sub max ($s)       { $s->@* ? List::Util::max($s->@*) : die "empty\n" }
sub min ($s)       { $s->@* ? List::Util::min($s->@*) : die "empty\n" }
sub new ($package) { bless [], $package }
sub pop ($s)       { $s->@* ? CORE::pop $s->@* : die "empty\n" }
sub push ($s, $e)  { CORE::push $s->@*, $e }
sub size ($s)      { scalar $s->@* }
sub top ($s)       { $s->@* ? $s->[-1] : die "empty\n" }
sub to_string ($s, @rest) {
   return '' unless $s->@*;
   my ($min, $max, $is_top, @lines) = ($s->min, $s->max, 1);
   for my $e (reverse $s->@*) {
      CORE::push @lines, sprintf '{%5s}', $e;
      my @features;
      CORE::push @features, 'top' if $is_top;
      CORE::push @features, 'min' if $e == $min;
      CORE::push @features, 'max' if $e == $max;
      $lines[-1] .= ' (' . join(', ', @features) . ')' if @features;
      $is_top = 0;
   }
   return join "\n", @lines;
}
1;
```
{% endraw %}

And now... this is all!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#095]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-095/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-095/#TASK2
[Perl]: https://www.perl.org/
[Algorithms, 4th edition]: https://algs4.cs.princeton.edu/home/
[`Stack` class]: https://algs4.cs.princeton.edu/code/javadoc/edu/princeton/cs/algs4/Stack.html
[overload]: https://perldoc.perl.org/overload
