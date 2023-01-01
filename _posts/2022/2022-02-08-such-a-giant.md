---
title: So pleased to use Perl
type: post
tags: [ perl ]
comment: true
date: 2022-02-08 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> [Perl][] is really pleasing to use.

I know that there's a lot of bad sentiment about the language, and I
don't care. While I can see a lot of the demerits, it's an outstanding
language, with a terrific ecosystem and tooling that's just so pleasing
to use.

As an example, I'm transforming a module and I've moved some tests from
their base directory `t` inside a sub-directory `t/V1`. So when I run
the tests with `prove` I got this:

```
$ prove
t/00-load.t .. 1/? # Testing App::Easer 0.011
t/00-load.t .. ok   
All tests successful.
Files=1, Tests=2,  0 wallclock secs ( 0.02 usr  0.00 sys +  0.05 cusr  0.00 csys =  0.07 CPU)
Result: PASS
```

Well yes, it just gets `t` by default, so we can be explicit:

```
$ prove t/*t t/*/*t
t/00-load.t ...................... 1/? # Testing App::Easer 0.011
t/00-load.t ...................... ok   
t/V1/01-single.t ................. ok    
t/V1/02-single-with-lib.t ........ ok   
t/V1/03-multilevel.t ............. ok    
t/V1/04-multilevel-jsons.t ....... ok   
t/V1/05-single-leaf.t ............ ok   
t/V1/10-stock_factory.t .......... ok    
t/V1/12-namenv.t ................. ok    
t/V1/15-spec-from-hash-or-mod.t .. ok    
t/V1/16-auto-env.t ............... ok    
t/V1/17-auto-env-command.t ....... ok    
t/V1/20-app-load.t ............... ok   
t/V1/30-custom-collect.t ......... ok   
t/V1/31-custom-sources.t ......... ok   
t/V1/40-fallback.t ............... ok   
t/V1/45.dispatch.t ............... ok   
t/V1/60-children-naming.t ........ ok   
t/V1/70-nested-children.t ........ ok   
t/V1/75-childrenbyprefix.t ....... ok   
All tests successful.
Files=19, Tests=145,  2 wallclock secs ( 0.09 usr  0.03 sys +  1.37 cusr  0.22 csys =  1.71 CPU)
Result: PASS
```

But wait! I put some tests inside a sub-sub-directory `t/V1/00-load`...
how cool would it be to have an option that recurses a directory of
tests? I would name it `-r`...

```
$ prove -r t
t/00-load.t ...................... 1/? # Testing App::Easer 0.011
t/00-load.t ...................... ok   
t/V1/00-load/01-default.t ........ ok   
t/V1/00-load/02-explicit.t ....... ok   
t/V1/00-load/03-direct.t ......... ok   
t/V1/01-single.t ................. ok    
t/V1/02-single-with-lib.t ........ ok   
t/V1/03-multilevel.t ............. ok    
t/V1/04-multilevel-jsons.t ....... ok   
t/V1/05-single-leaf.t ............ ok   
t/V1/10-stock_factory.t .......... ok    
t/V1/12-namenv.t ................. ok    
t/V1/15-spec-from-hash-or-mod.t .. ok    
t/V1/16-auto-env.t ............... ok    
t/V1/17-auto-env-command.t ....... ok    
t/V1/20-app-load.t ............... ok   
t/V1/30-custom-collect.t ......... ok   
t/V1/31-custom-sources.t ......... ok   
t/V1/40-fallback.t ............... ok   
t/V1/45.dispatch.t ............... ok   
t/V1/60-children-naming.t ........ ok   
t/V1/70-nested-children.t ........ ok   
t/V1/75-childrenbyprefix.t ....... ok   
All tests successful.
Files=22, Tests=157,  2 wallclock secs ( 0.11 usr  0.04 sys +  1.54 cusr  0.25 csys =  1.94 CPU)
Result: PASS
```

I know... it's easy to make me happy 😄

Stay safe folks!


[Perl]: https://www.perl.org/
