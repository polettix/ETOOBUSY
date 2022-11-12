---
title: Pointer to element
type: post
tags: [ perl ]
comment: true
date: 2020-11-14 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> There's a gem in [Perl Monks][] that I always struggle finding... again:
> [Recursively walk a hash to get to an element][post].

From time to time I hit this problem in [Perl][]: traverse a hash of hashes
to get to a specific item, with the *path* provided via an array of keys.
Or, as laid out by the [post][] itself:

> How do I start with `%myhash`, and a list of keys `qw(bedrock flintstone
> fred)`, and get access to the value at `$myhash{bedrock}{flintstone}{fred}`?

[Recursively walk a hash to get to an element][post] gives the answer, one
that I always struggle finding when I need it:

```perl
sub pointer_to_element {
  require List::Util;
  return List::Util::reduce(sub { \($$a->{$b}) }, \shift, @_);
}
```

It returns a *reference* to a slot in a hash, which can be used to either
read or write a value in the hash:

```perl
my %hash = (hello => {to => 'everyone'});
my $scalar_ref = pointer_to_element(\%hash, qw< hello to >);
print $$scalar_ref, "\n";    # prints "everyone"
$$scalar_ref = 'everybody';
print "$hash{hello}{to}\n";  # prints "everybody"
```

[merlyn] gets every possible credit for this clever piece of code, of
course.

Now... I hope it will not take me long to find it again in the future!

[post]: https://www.perlmonks.org/?node_id=443584
[Perl]: https://www.perl.org/
[Perl Monks]: https://www.perlmonks.org/
[merlyn]: https://www.perlmonks.org/?node_id=9073
