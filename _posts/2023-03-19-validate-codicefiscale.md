---
title: 'First release of Validate::CodiceFiscale'
type: post
tags: [ perl ]
comment: true
date: 2023-03-19 00:01:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I pushed the first release of [Validate::CodiceFiscale][].

I recently had to validate some *Codice Fiscale* (sort of social security
number) and turned to the mighty [CPAN][]. It contains a module that can be
used to this goal, but I was not too enthusiastic about it.

My main itch is about this:

```perl
$obj = String::CodiceFiscale->parse('WLLLRY87T18Z404B');
 
unless ($obj) {                 # check for errors
   print "We have an error: " . String::CodiceFiscale->error;
}
```

In my very humble opinion, parse errors should be collected at the point of
parsing, not with some *global* mechanism like a class method. Even though
I'm probably not going to use it anywhere near parallel stuff that might
suffer from it, I just don't like the deliberate introduction of some tech
debt that is easily avoidable from the beginning.

So I had two paths: suggest a different interface, or roll another module. I
quickly opted for the latter, because a different interface would mean
breaking wherever that module has been used so far, at leat by the original
author.

So I went on with [Validate::CodiceFiscale][], here's the initial SYNOPSIS:

```perl
use Validate::CodiceFiscale qw< assert_valid_cf is_valid_cf validate_cf >;

my $valid   = 'RSSMRA98S03B833G';
my $invalid = 'RSICRL99C51C967X';

# the first does not warn, the second does warn
eval { assert_valid_cf($valid);   1 } or warn "died: $@";
eval { assert_valid_cf($invalid); 1 } or warn "died: $@";

# plain boolean test, any error short-circuits
if (is_valid_cf($cf)) { ... }

# get everything that's wrong
if (my $errors = validate_cf($invalid)) {
   say for $errors->@*; # array with error report, one line per error
}

# it's possible to pass additional validation options, like specific
# data. All are optional, if present they're validate, otherwise
# ignored.
assert_valid_cf($cf,
   {
      data => {
         name => 'Foo',
         surname => 'Bar',
         sex => 'f',
         birthdate => '1998-03-11',
         birthplace => 'B833',
      }
   }
);

# the assertion short-circuits by default, failing at the first
# error. It's possible to check everyting and get a longer error
# message, in case.
assert_valid_cf($cf, { all_errors => 1 });

# it's also possible to wrap the error generation, by returning the
# exception to throw
assert_valid_cf($cf,
   {
      all_errors => 1,
      on_error => sub {
         my @errors = @_;
         return "number of errors: $n_errors\n";
      }
   }
);

# of course, it's possible to throw the exception directly
use Ouch;
assert_valid_cf($cf, { on_error => sub { ouch 400, $_[0] } });
```

I'll be eager to see the results of [CPAN Testers][], as usual, even though
I suspect there's something weird going on there. I released a couple of
modules recently, and it's a bit weird that I didn't get any feedback so
far. Let's see.

Stay safe and validated!


[Perl]: https://www.perl.org/
[Validate::CodiceFiscale]: https://metacpan.org/pod/Validate::CodiceFiscale
[CPAN]: https://metacpan.org/
[String::CodiceFiscale]: https://metacpan.org/pod/String::CodiceFiscale
[CPAN Testers]: https://cpantesters.org/
