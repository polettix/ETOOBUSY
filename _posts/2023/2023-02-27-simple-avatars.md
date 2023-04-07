---
title: Simple avatars
type: post
tags: [ perl, rakulang, random, fun ]
comment: true
date: 2023-02-27 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Generating simple avatars.

Avatars/profile images seem to be kind of an obsession to me, as I keep
returning on at least two related topics:

- finding public domain stuff that can be used to this goal (latest on
  this channel: [Repo icons sources][])
- automatic generation of stuff.

This time we're on the second bullet, and I guess you saw it coming
because I've been rambling about random (but reproducible) number
generation in my latest posts.

Here's a simple implementation that gives back an array of arrays, each
representing a line with *pixels* represented by individual chars (empty
or `#`):

```perl
sub avathar ($n = undef, $seed = undef) {
   $n //= 16;
   my $n_2   = int(($n + 1) / 2);
   my $r = Randomish->new($seed);
   return [
      map {
         my @half_line = map { $r->bit ? ' ' : '#' } 1 .. $n_2;
         my @reflected = reverse(@half_line);
         shift @reflected if $n % 2;
         [@half_line, @reflected];
      } 1 .. $n
   ];
} ## end sub avathar
```

The idea is to generate something that is symmetric along the vertical
axis. I took this idea of symmetry from *somewhere*, but I have to admit
that I can't remember where. Anyway, I guess this must be some
inspiration that came to *a lot* of people, right?

And yes! There's a [Raku][] counterpart too:

```raku
sub avathar ($n = Nil, $seed = Nil) {
   $n //= 16;
   my $n-half = ($n + 1) div 2;
   my $rnd = Randomish.new(:$seed);
   return (^$n).map({
      my @half-line = (^$n-half).map({ $rnd.bit() ?? ' ' !! '#' });
      my @reflected = @half-line.reverse;
      @reflected.shift if $n % 2;
      (@half-line, @reflected).flat.Array;
   }).Array;
}
```

An example output (with n equal to 8 and seed set to `polettix`) is the
following:

```
  #  #  
 ##  ## 
##    ##
 # ## # 
# #  # #
  #  #  
# #### #
# #  # #
```

Raising n up to 16 gives us:

```
  #  ##  ##  #  
##   # ## #   ##
# #   #  #   # #
# ### #  # ### #
#  ####  ####  #
 ##   #  #   ## 
      #  #      
    ## ## ##    
       ##       
  ## # ## # ##  
#   # #  # #   #
    ## ## ##    
  ####    ####  
# ###      ### #
# # ######## # #
      ####
```

Overall, I thought I would have to struggle more and I'm happy with the
result.

Stay safe!


[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Repo icons sources]: {{ '/2023/01/18/repo-icons-sources/' | prepend: site.baseurl }}
