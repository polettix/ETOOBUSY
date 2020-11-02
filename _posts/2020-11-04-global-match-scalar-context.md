---
title: Global matching in scalar context
type: post
tags: [ perl, parsing ]
comment: true
date: 2020-11-04 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Today I Learned: global matching in scalar context.

In last post [Fantasy Name Generator - a parser][] I went a bit *fast* over an issue I had with `pf_regexp` as it was implemented:

```perl
sub pf_regexp {
   my ($rx, @forced_retval) = @_;
   return sub {
      my (undef, $retval) = ${$_[0]} =~ m{\G()$rx}cgmxs or return;
      return scalar(@forced_retval) ? [@forced_retval] : [$retval];
   };
}
```

Fact is that this capturing is a bit too... *enthusiastic*. Consider the case
where I want to get only one letter at a time out of a string of letters:

```perl
my $rxp = pf_regexp(qr{(\w)});
my $string = 'abcde';
my $capture = $rxp->(\$string);
say "captured<@$capture> - left at ", pos $string;
```

Running this program yields:

```
$ perl prova2.pl 
captured<a> - left at 5
```

We did indeed capture `a` only... but we ditched also all the rest of
the characters (note that `pos` returns 5 instead of 1). Fact is, the
*global matching* in `pf_regexp` is greedy and gets them all. 

Can we do anything about this? Sure we can!

The problem with the *overall capture* comes from the fact that we are
using a *list context* to do the capture:

```perl
      my (undef, $retval) = ${$_[0]} =~ m{\G()$rx}cgmxs or return;
```

This is what [perlretut][] has to say:

> The modifier `/g` stands for global matching and allows the matching
> operator to match within a string as many times as possible.

This confirms our fears: everything is matched as long as it's possible.
But there's hope:

> In scalar context, successive invocations against a string will have
> /g jump from match to match, keeping track of position in the string
> as it goes along.

So the answer is easy... we have to ditch the *list context* and adopt a
*scalar context* instead:

```perl
sub pf_regexp {
   my ($rx, @forced_retval) = @_;
   return sub {
      scalar(${$_[0]} =~ m{\G()$rx}cgmxs) or return;
      return scalar(@forced_retval) ? [@forced_retval] : [$2];
   };
}
```

With this modified version, our previous program behaves like we expect:

```
$ perl prova2.pl 
captured<a> - left at 1
```

So... this is what ended up as a patch in the library. Yay!

[Fantasy Name Generator - a parser]: {{ '/2020/11/03/fng-parsing/' | prepend: site.baseurl }}
[perlretut]: https://perldoc.perl.org/perlretut
