---
title: Think Bayes in Raku - Pmf class, take 2
type: post
tags: [ maths, probability, rakulang ]
comment: true
date: 2021-08-13 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A new take on [Think Bayes in Raku - Pmf class][].

In previous post [Think Bayes in Raku - Pmf class][] we saw a (simple)
class for dealing with *probability mass functions*. I received quality
feedback on it, I hope I'll be able to remember that stuff in the
future.

Looking through [the second edition of Think Bayes][Think Bayes 2e] I
realized that the `multiply` method is... *suboptimal*:

```
method multiply ($key, $factor) { ...
```

This does the multiplication for a single key. It's a good building
block, yes... but most of the times we're going to multiply *the whole*
probability mass function times the *likelihood* for all slots in the
Pmf. As such, then, it makes sense to get a whole mapping of
*likelihood* values, and do the multiplication for them all:

```raku
multi method multiply (%h, :$default = Nil) {
   for %!value-for.keys -> $key {
      %!value-for{$key} *= %h{$key}:exists ?? %h{$key}
         !! defined($default) ?? $default
         !! die "missing key '$key' in multiplier";
   }
   return self;
}
```

*Yes*, I switched to `multi method` so that I can keep the old
`multiply` too. Call me sentimental.

The `$default` (named) parameter is there to account for the possibility
of missing keys in the likelihood hash `%h`. By default it complains
loudly. Should we have a default, though, we can set it there.

Now we can also add some *eye candy*:

```raku
multi sub infix:<*=> (Pmf:D $l is rw, %r) { return $l.multiply(%r) }
multi sub infix:<*>  (Pmf:D $l is rw, %r) { return $l.clone.multiply(%r) }
```

This allows us to write stuff like this:

```
my $prior = Pmf.new(<A 1 B 1 C 1>);
my %likelihood = A => 1/2, B => 3/4, C => 1/8;
my $posterior = $prior * %likelihood;
```

or this:

```
my $pmf = Pmf.new(<A 1 B 1 C 1>);
my %likelihood = A => 1/2, B => 3/4, C => 1/8;
$pmf *= %likelihood;
```

which, I think, is *super-cool*.

Here's the new, revised implementation:

```raku
use v6;

class Pmf {
   has %.value-for;

   multi method new (@data) { self.new(value-for => hash(@data)) }
   multi method new (%data) { self.new(value-for => %data)       }
         method clone ()    { self.new(%.value-for) }

   method gist () {
      ( |'---', |%!value-for.keys.sort.map: { "  «$_» %!value-for{$_}" } )
         .head(100).join($?NL)
   }

   method total () { return [+] %!value-for.values }

   method normalize (Numeric:D $sum = 1) {
      my $total = self.total or return self;
      my $factor = $sum / $total;
      %!value-for.values »*=» $factor;
      return self;
   }

   method set ($key, $value) {
      %!value-for{$key} = $value;
      return self;
   }

   method increment ($key, $amount = 1) {
      %!value-for{$key} += $amount;
      return self;
   }

   multi method multiply ($key, $factor) {
      %!value-for{$key} *= $factor;
      return self;
   }

   multi method multiply (%h, :$default = Nil) {
      for %!value-for.keys -> $key {
         %!value-for{$key} *= %h{$key}:exists ?? %h{$key}
            !! defined($default) ?? $default
            !! die "missing key '$key' in multiplier";
      }
      return self;
   }

   method probability ($key) { self.P($key) }
   method P ($key) {
      die "no key '$key' in PMF" unless self.value-for{$key}:exists;
      my $T = self.total or die 'Empty PMF, sorry!';
      return self.value-for{$key} / $T;
   }
}

multi sub infix:<*=> (Pmf:D $l is rw, %r) { return $l.multiply(%r) }
multi sub infix:<*>  (Pmf:D $l is rw, %r) { return $l.clone.multiply(%r) }

sub MAIN {
   #my $pmf = Pmf.new(value-for => <A 10 B 20>.hash);
   my $pmf = Pmf.new(<A 10 B 20>);
   say $pmf;

   $pmf = Pmf.new(('A', 6));
   say $pmf;
   $pmf.increment('A', 4).increment('B', 20);
   $pmf.say;
   $pmf.normalize.say;
   $pmf.probability('A').put;

   $pmf = Pmf.new;
   $pmf.set('A', 10).set('B', 20);
   $pmf.probability('B').put;

   $pmf.multiply('A', 2);
   $pmf.say;
   $pmf.probability('B').put;

   my $cookie = Pmf.new(('Bowl 1', 1, 'Bowl 2', 1).hash);
   $cookie.multiply('Bowl 1', 3/4);
   $cookie.multiply('Bowl 2', 1/2);
   say 'probability it came from Bowl 1: ', $cookie.P('Bowl 1');

   {
      my $cookie = Pmf.new(hash('Bowl 1', 1, 'Bowl 2', 1));
      my %lhood  = 'Bowl 1' => 3/4, 'Bowl 2' => 1/2;

      my $clone = $cookie * %lhood;
      put 'cookie: ', $cookie.gist;
      put 'clone:  ', $clone.gist;
      say 'probability it came from Bowl 1: ', $clone.P('Bowl 1');

      $cookie *= hash('Bowl 1' => 0.2, 'Bowl 2' => 0.9);
      say 'probability it came from Bowl 1: ', $cookie.P('Bowl 1');
   }
}
```

Stay safe folks!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Think Bayes in Raku - Pmf class]: {{ '/2021/08/06/tbr-class-pmf' | prepend: site.baseurl }}
[Think Bayes 2e]: https://greenteapress.com/wp/think-bayes/
