---
title: PWC209 - Special Bit Characters
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-03-23 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#209][]. Enjoy!

# The challenge

> You are given an array of binary bits that ends with 0.
>
> Valid sequences in the bit string are:
>
>     [0] -decodes-to-> "a"
>     [1, 0] -> "b"
>     [1, 1] -> "c"
>
> Write a script to print 1 if the last character is an “a” otherwise print
> 0.
>
> **Example 1**
>
>     Input: @bits = (1, 0, 0)
>     Output: 1
>
>     The given array bits can be decoded as 2-bits character (10) followed
>     by 1-bit character (0).
>
> **Example 2**
>
>     Input: @bits = (1, 1, 1, 0)
>     Output: 0
>
>     Possible decode can be 2-bits character (11) followed by 2-bits
>     character (10) i.e. the last character is not 1-bit character.


# The questions

No questions! Well, maybe one: why an *array* of bits, and not a string or
some other numeric value to scan?

# The solution

My question was not only to bug our fine host [manwar][], but also because I
found it easy to address this challenge with a *regular expression*:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN ($bits) { put special-bits-characters($bits.comb.Array) }

sub special-bits-characters ($bits) {
   $bits.join('') ~~ m{^ [ 1 <[ 0 1 ]> | 0 ]* 0 $} ?? 1 !! 0;
}
```

So I have an array as the official interface of my function, but it comes
from a string and I turn it into a string as soon as it enters the function.
And I'm skeptical about cryptocurrencies!

[Perl][] is pretty much the same, even though I admit to being able to read
regular expressions with a bit more ease:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

my @bits = map { split m{}mxs } @ARGV;
say special_bits_characters(\@bits);

sub special_bits_characters ($bits) {
   join('', $bits->@*) =~ m{\A (?: 1[01] | 0 )* 0 \z}mxs ? 1 : 0;
}
```

As I'm lazy and I don't want to explain what the regular expression does,
I'll let [YAPE::Regex::Explain][] do the heavy lifting, with *just a bit of
editing* for clarity on my side:

```

The regular expression:

(?msx: \A (?: 1[01] | 0 )* 0 \z )

matches as follows:
  
NODE                     EXPLANATION
----------------------------------------------------------------------
(?msx:                   group, but do not capture (with ^ and $      
                         matching start and end of line) (with .      
                         matching \n) (disregarding whitespace and    
                         comments) (case-sensitive):                  
----------------------------------------------------------------------
  \A                       the beginning of the string                
----------------------------------------------------------------------
  (?:                      group, but do not capture (0 or more times      
                           (matching the most amount possible)):
----------------------------------------------------------------------
    1                        '1'                                      
----------------------------------------------------------------------
    [01]                     any character of: '0', '1'               
----------------------------------------------------------------------
   |                        OR                                        
----------------------------------------------------------------------
    0                        '0'                                      
----------------------------------------------------------------------
  )*                       end of grouping                            
----------------------------------------------------------------------
  0                        '0'                                        
----------------------------------------------------------------------
  \z                       the end of the string                      
----------------------------------------------------------------------
)                        end of grouping                              
----------------------------------------------------------------------
```

[Perl][] is wonderful (well.. [Raku][] too!)

Stay safe!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#209]: https://theweeklychallenge.org/blog/perl-weekly-challenge-209/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-209/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[YAPE::Regex::Explain]: https://metacpan.org/pod/YAPE::Regex::Explain
