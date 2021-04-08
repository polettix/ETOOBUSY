---
title: PWC107 - List Methods
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-04-08 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#107][].
> Enjoy!

# The challenge

> Write a script to list methods of a package/class.

# The questions

As it often happens, we fall into the *foggy* category of challenge here,
one that --I suppose-- leaves space to the imagination of the interviewed
and allows delving into their thought process.

The first obvious question is *what language should we do this for?* I know
this is the [Perl][] weekly challenge, but:

- implementations from other languages are welcome (I already told you that
  [Mohammad Sajid Anwar is amazing][])
- even from [Perl][], we might want to understand the methods present in the
  package/class of some other language.

In lack of details, though, we play it simple and avoid
cross-introspections; moreover, I like [Perl][] and I'll stick with this.

The second question is *can we look for the solution in internet*? I need to
use this kind of introspection so rarely that I always keep forgetting it (I
only vaguely remember about the hashes ending in `::`), which is reassuring
because in general you *should not* need to use introspection for day by
day challenge solving!

The last question actually came *after* I found a solution... so we'll defer
it into the solution part.

# The solution

Asking the web is often a good starting point: [perl list methods in
package][]?

This time, the first (non-ad) answer was the sweet answer to the challenge:
[How do I list available methods on a given object or package in Perl?]

Which leads us to this (slightly redacted) solution:

```perl
sub list_methods ($module) {
   no strict 'refs';
   return grep { defined &{$module . '::' . $_} } keys %{$module . '::'};
}
```

When trying this on the example `Calc` package, we can definitely notice a
difference though:

```
Challenge | Solution
----------+----------
BEGIN     |
mul       | new
div       | div
new       | add
add       | mul
```

(The two lists are sorted differently because items in a hash appear in a
random order).

Where's the `BEGIN` method?!? It turns out that the `defined` is filtering
it out, because `BEGIN` is *not* really available. In other words, the
symbol is there but there's no method associated to it, so we ignore it.
This is easily seen by avoiding the `grep` filter:

```perl
sub list_methods ($module) {
   no strict 'refs';
   return keys %{$module . '::'};
}
```

This gives us the same items, but... possibly much more too. As an example,
let's add a class variable in `Calc`:

```perl
package Calc;

use strict;
use warnings;

our $intruder; # << "I am the intruder!!!"

sub new { bless {}, shift; }
sub add { }
sub mul { }
sub div { }

1;
```

Here is what we get back:

```intruder
intruder
new
div
add
mul
BEGIN
```

Well, I guess this settles it - the `defined` must get back, so that we only
list *methods* in the package namespace, avoiding other slots in the glob.

I like my little wrapping programs to accept some challenge input as...
*input*, so in this case I had the problem of dynamically load the package
after getting its name from the command line argument.

I would normally turn to [Module::Runtime][] for this, but it seemed
overkill in this case so I coded a poor man's version (which does not
account for all bugs and intricacies of several different versions of
`perl`):

```perl
sub load ($module) { require("$module.pm" =~ s{::}{/}grmxs); $module }
```

I find that I like option `r` of the [s operator][] more and more 🤓

So here we go, the complete solution:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub list_methods ($module) {
   no strict 'refs';
   return grep { defined &{$module . '::' . $_} } keys %{$module . '::'};
}

sub load ($module) { require("$module.pm" =~ s{::}{/}grmxs); $module }

use FindBin '$Bin';
use lib $Bin;;
my $module = shift // 'Calc';
say for list_methods(load($module));
```

Have a nice... remainder of week and stay safe people!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#107]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-107/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-107/#TASK2
[Perl]: https://www.perl.org/
[Mohammad Sajid Anwar is amazing]: {{ '/2020/12/08/manwar-is-amazing/' | prepend: site.baseurl }}
[perl list methods in package]: https://duckduckgo.com/?t=ffab&q=perl+list+methods+in+package&ia=web
[How do I list available methods on a given object or package in Perl?]: https://stackoverflow.com/questions/910430/how-do-i-list-available-methods-on-a-given-object-or-package-in-perl
[Module::Runtime]: https://metacpan.org/pod/Module::Runtime
[s operator]: https://perldoc.perl.org/perlop#s/PATTERN/REPLACEMENT/msixpodualngcer
