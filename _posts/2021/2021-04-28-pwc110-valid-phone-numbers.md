---
title: PWC110 - Valid Phone Numbers
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-04-28 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#110][]. Enjoy!

# The challenge

> You are given a text file. Write a script to display all valid phone
> numbers in the given text file.
>
> Acceptable Phone Number Formats:
>
>     +nn  nnnnnnnnnn
>     (nn) nnnnnnnnnn
>     nnnn nnnnnnnnnn
>
> Example, input file:
>
>     0044 1148820341
>      +44 1148820341
>       44-11-4882-0341
>     (44) 1148820341
>       00 1148820341
>
> Example, output:
>
>     0044 1148820341
>      +44 1148820341
>     (44) 1148820341

# The questions

There's some... *induction* required in this challenge, especially for
what the input is supposed to look like with respect to spaces:

- do we tolerate leading/trailing spaces? From the templates it seems
  not, although the examples seem to imply a different story (the `+44`
  row is a *pass*);
- do we insist on the exact spacing between the first and the second
  part? I mean, the `+nn` template seems to require *two* spaces before
  the rest, but the passing example with `+44` has only one (having
  moved the other one before the `+44`);
- should we stick to plain spaces, or does any spacing do?

We'll take the examples into account... and consider any spacing
acceptable.

# The solution

The task is about checking a file, so there are two halves.

Going top-down, we first have to make sure to go through all the lines
in the file. Is it a real file? Something different? We will accept
anything that can act as a file:

```perl
sub valid_phone_numbers ($f) {
   $f = ref($f)     ? $f
      : ($f eq '-') ? \*STDIN
      :               do { open my $h, '<', $f or die "$!\n"; $h };
   is_phone_number_acceptable(s{\A\s+|\s+\z}{}rgmxs) && print while <$f>;
}
```

The input can be a filename (interpreting `-` as *take standard input*,
as it often happens) or a filehandle. Whatever the case, we need a
filehandle, so we make sure that `$f` holds one eventually.

Then we iterate through the file, trimming the lines before doing the
check `is_phone_number_acceptable` and printing them if they comply.

The fact that we also accept filehandles makes it easy to code a
*default case* where we feed the challenge example as input:

```perl
my $f = shift // do {
   my $input = <<'END';
0044 1148820341
 +44 1148820341
  44-11-4882-0341
(44) 1148820341
  00 1148820341
END
   open my $fh, '<', \$input;
   $fh;
};

valid_phone_numbers($f);
```

OK, let's move on to the phone number check function:

```
sub is_phone_number_acceptable ($n) {
   scalar(
      $n =~ m{
         \A
         (?:
               \+\d\d     # +nn
            |  \(\d\d\)   # (nn)
            |  \d{4}      # nnnn
         )
         \s+
         \d{10}           # nnnnnnnnnn
         \z
      }mxs
   );
}
```

This overly-verbose regular expression takes advantage of [Perl][]'s
`/x` modifier, which allows organizing complex expressions with
comments.

The check itself demands that there are no leading or trailing spaces;
it just seemd better to have a more *precise* test, and remove them
before calling the function.

There is a first *non-capturing* group that addresses the first part;
here we have three possible alternatives for the *prefix*:

- *one plus sign, followed by two digits*,
- or *one opening round parenthesis, two digits, one closing round
  parenthesis*,
- or *exactly four digits*.

Then, after *one or more spaces*, we have *exactly ten digits*.

Using a non-capturing group here is a small performance improvement, but
also a hint to the next programmer that we're not really interested in
capturing anything, just in making sure that the alternatives are
grouped together.

I'm not sure why I felt the urge to wrap the whole thing with `scalar`;
again, my default here was probably to make sure that this function
behaves like a boolean (i.e. scalar) test, whatever the way it is
called. Call me a paranoid.

You might be interested into the whole program, so here it is:

```
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub is_phone_number_acceptable ($n) {
   scalar(
      $n =~ m{
         \A
         (?:
               \+\d\d     # +nn
            |  \(\d\d\)   # (nn)
            |  \d{4}      # nnnn
         )
         \s+
         \d{10}           # nnnnnnnnnn
         \z
      }mxs
   );
}

sub valid_phone_numbers ($f) {
   $f = ref($f)     ? $f
      : ($f eq '-') ? \*STDIN
      :               do { open my $h, '<', $f or die "$!\n"; $h };
   is_phone_number_acceptable(s{\A\s+|\s+\z}{}rgmxs) && print while <$f>;
}

my $f = shift // do {
   my $input = <<'END';
0044 1148820341
 +44 1148820341
  44-11-4882-0341
(44) 1148820341
  00 1148820341
END
   open my $fh, '<', \$input;
   $fh;
};

valid_phone_numbers($f);
```

Have fun and... stay safe!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#110]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-110/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-110/#TASK1
[Perl]: https://www.perl.org/
