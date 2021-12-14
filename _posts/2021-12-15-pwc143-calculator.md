---
title: PWC143 - Calculator
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-12-15 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#143][]. Enjoy!

# The challenge


> You are given a string, `$s`, containing mathematical expression.
>
> Write a script to print the result of the mathematical expression. To
> keep it simple, please only accept `+ - * ()`.
>
> **Example 1:**
> 
>     Input: $s = "10 + 20 - 5"
>     Output: 25
>
> *Example 2:**
>
>     Input: $s = "(10 + 20 - 5) * 2"
>     Output: 50

# The questions

Assuming positive integers as operands, i.e. no starting with a `-` sign
and no decimals.

# The solution

*Oh boy... can I haz cheat?*

Well it's our call:

```raku
sub MAIN (Str:D $expression) {
    use MONKEY-SEE-NO-EVAL;
    die 'invalid' unless $expression ~~ / ^ <[ 0..9 + \- * ( ) \s ]>* $ /;
    put EVAL($expression);
}
```

Ah, the EVIL might EVAL...

Well, let's do things the clean way too:

```raku
#!/usr/bin/env raku
use v6;

grammar Calc {
    rule TOP        { ^ <expression> $ }
    rule expression { <term>+ %% $<op>=(['+'|'-']) | <group> }
    rule term       { <factor>+  %% $<op>=(['*']) }
    rule factor     { <value> | <group> }
    rule group      { '(' <expression> ')' }
    token value     { 0 | <[ 1..9 ]> \d* }
}

class Actions {
   method TOP ($/) { $/.make: $<expression>.made }
   method expression ($/) {
      if $<group> { $/.make: $<group>.made }
      else        { $/.make: self!calc($<term>, $<op>) }
   }
   method term ($/) { $/.make: self!calc($<factor>, $<op>) }
   method factor ($/) {
      if $<group> { $/.make: $<group>.made }
      else        { $/.make: $<value>.made }
   }
   method group ($/) { $/.make: $<expression>.made }
   method value ($/) { $/.make: +$/ }

   method !calc ($operands, $operators) {
      my ($retval, @vals) = $operands».made;
      my @ops = $operators.map: ~*;
      for @ops Z @vals -> ($_, $val) {
         when '*' { $retval *= $val }
         when '+' { $retval += $val }
         when '-' { $retval -= $val }
      }
      return $retval;
   }
}

sub MAIN ($expression) {
   my $calc = Calc.parse($expression, actions => Actions)
      or die 'cannot parse input expression';
   say $calc.made;
}
```

This was heavily inspired by some code by [Andrew Shitov][], except that
I had to re-write the actions and refactor a bit.

For the [Perl][] translation we will get some help from [cglib-perl][]'s
[Parsing.pm][], which is embedded directly into the solution. The
initial part is the interesting one though, because it contains our
grammar and entry point:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say parse(shift);

# main entry point, useful for extracting the return value
sub parse ($exp) { return pf_PARSE(expression())->($exp)->[0] }

# <term> [+/- <term> [+/- <term> [...]]] | <group>
sub expression { pf_alternatives(canned_ops(term(), '-', '+'), group()) }

# <factor> [* <factor> [* <factor> [...]]]
sub term { canned_ops(factor(), '*') }

# <value> | <group>
sub factor { pf_alternatives(value(), group()) }

# '(' <expression> ')'
sub group {
   return sub {
      state $matcher = pf_sequence('(', expression(), ')');
      my $match = $matcher->(@_) or return;
      return $match->[1];
   }
}

# some integer without sign
sub value { pf_regexp(qr{\s*(0|[1-9]\d*)\s*}) }

# implementation of operand [op operand [op operand [...]]]
sub canned_ops ($operand, @operators) {
   my $ops = join '|', map { quotemeta } @operators ;
   my $op_opd = pf_sequence(pf_regexp(qr{\s*($ops)\s*}), $operand);
   my $matcher = pf_sequence($operand, pf_repeated($op_opd));
   return sub {
      my $match = $matcher->(@_) or return;
      my $retval = $match->[0][0];
      for my $opv ($match->[1]->@*) {
         my ($op, $val) = map { $_->[0] }$opv->@*;
         if    ($op eq '*') { $retval *= $val }
         elsif ($op eq '+') { $retval += $val }
         elsif ($op eq '-') { $retval -= $val }
      }
      return [ $retval ];
   }
}
```

The `canned_ops` takes care to implement a sequence of operations of the
same "nature", i.e. summish or multiplicativish.

As anticipated, the rest is [Parsing.pm][]:

```perl
# parsing facilities
sub pf_alternatives {
   my (@A, $r) = @_;
   return sub { (defined($r = $_->($_[0])) && return $r) for @A; return };
}

sub pf_exact {
   my ($wlen, $what, @retval) = (length($_[0]), @_);
   unshift @retval, $what unless scalar @retval;
   return sub {
      my ($rtext, $pos) = ($_[0], pos(${$_[0]}) || 0);
      return if length($$rtext) - $pos < $wlen;
      return if substr($$rtext, $pos, $wlen) ne $what;
      pos($$rtext) = $pos + $wlen;
      return [@retval];
   };
}

sub pf_list {
   my ($w, $s, $sep_as_last) = @_; # (what, separator, sep_as_last)
   $s = pf_exact($s) if defined($s) && !ref($s);
   return sub {
      defined(my $base = $w->($_[0])) or return;
      my $rp = sub { return ($s && !($s->($_[0])) ? () : $w->($_[0])) };
      my $rest = pf_repeated($rp)->($_[0]);
      $s->($_[0]) if $s && $sep_as_last; # attempt last separator?
      unshift $rest->@*, $base;
      return $rest;
   };
}

sub pf_match_and_filter {
   my ($matcher, $filter) = @_;
   return sub {
      my $match = $matcher->($_[0]) or return;
      return $filter->($match);
   };
}

sub pf_PARSE {
   my ($expression) = @_;
   return sub {
      my $rtext = ref $_[0] ? $_[0] : \$_[0]; # avoid copying
      my $ast = $expression->($rtext) or die "nothing parsed\n";
      my $pos = pos($$rtext) || 0;
      my $delta = length($$rtext) - $pos;
      return $ast if $delta == 0;
      my $offending = substr $$rtext, $pos, 72;
      substr $offending, -3, 3, '...' if $delta > 72;
      die "unknown sequence starting at $pos <$offending>\n";
   };
}

sub pf_regexp {
   my ($rx, @forced_retval) = @_;
   return sub {
      scalar(${$_[0]} =~ m{\G()$rx}cgmxs) or return;
      return scalar(@forced_retval) ? [@forced_retval] : [$2];
   };
}

sub pf_repeated { # *(0,-1) ?(0,1) +(1,-1) {n,m}(n,m)
   my ($w, $m, $M) = ($_[0], $_[1] || 0, (defined($_[2]) ? $_[2] : -1));
   return sub {
      my ($rtext, $pos, $lm, $lM, @retval) = ($_[0], pos ${$_[0]}, $m, $M);
      while ($lM != 0) { # lm = local minimum, lM = local maximum
         defined(my $piece = $w->($rtext)) or last;
         $lM--;
         push @retval, $piece;
         if ($lm > 0) { --$lm } # no success yet
         else         { $pos = pos $$rtext } # ok, advance
      }
      pos($$rtext) = $pos if $lM != 0;  # maybe "undo" last attempt
      return if $lm > 0;    # failed to match at least $min
      return \@retval;
   };
}

sub pf_sequence {
   my @items = map { ref $_ ? $_ : pf_exact($_) } @_;
   return sub {
      my ($rtext, $pos, @rval) = ($_[0], pos ${$_[0]});
      for my $item (@items) {
         if (defined(my $piece = $item->($rtext))) { push @rval, $piece }
         else { pos($$rtext) = $pos; return } # failure, revert back
      }
      return \@rval;
   };
}

{ my $r; sub pf_ws  { $r ||= pf_regexp(qr{(\s+)}) } }
{ my $r; sub pf_wso { $r ||= pf_regexp(qr{(\s*)}) } }
```

Stay safe folks!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#143]: https://theweeklychallenge.org/blog/perl-weekly-challenge-143/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-143/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Andrew Shitov]: https://andrewshitov.com/2018/10/31/creating-a-calculator-with-perl-6-grammars/
[cglib-perl]: https://github.com/polettix/cglib-perl
[Parsing.pm]: https://github.com/polettix/cglib-perl/blob/master/Parsing.pm
