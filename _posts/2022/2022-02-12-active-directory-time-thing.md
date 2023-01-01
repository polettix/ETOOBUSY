---
title: Active Directory time thing
type: post
tags: [ ldap, active directory ]
comment: true
date: 2022-02-12 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Converting from and to the Active Directory way of representing time.

OK, let's make one thing clear **up front**: I'm no expert in LDAP or
Active Directory, and if there's one *socratic* thing I know about time
representation is that they are *beyond*. You draw the line, then go
*beyond*. So the code I'm describing here basically works for me in 2022
dealing with problems in and around 2022, where precision to the second
is really not a thing because Active Directory is used to track times
whose higher-level evolution mechanism goes by the day/days.

> This is in no way to deflect criticism of what I'm going to write,
> which is appreciated. This is a warning that what I'm writing may be,
> and probably is indeed, flawed and working for me only, so you have to
> double check that it works for you too in all your cases. Ultimately,
> it will be your responsibility to check this.

Ready? Let's start with what got me up to speed.

Many attributes in Active Directory, most notably for me
[accountExpires][] (sorry, I write it as I read it from the LDAP
responses), are represented with a huge, **64-bits** integer (well, 63
actually) that

> \[...\] represents the number of 100-nanosecond intervals since
> January 1, 1601 (UTC).

I really don't want to go into the details about it, you know. Why
January 1st, 1601 and not, say, [October 15th, 1582][greg] which is less
than 20 years before (so perfectly reachable). Or, why the unit (tenth
of a microsecond). Or why they smashed the most significant bit, which I
understand is never used. I mean, it is what it is.

From my practical perspective, I'm good in using a lot of stuff that
uses the [Unix epoch][], including the venerable
[gmtime][]/[localtime][] routines in [Perl][]. So there's a bit of
Fahrenheit to Celsius conversion to be done, and I'm OK with a formula.

In our case, there are two numbers to keep in mind:

- *epoch*s are expressed in seconds, so $1\_{eu} = 10^7\_{adu}$ (where
  *eu* stands for *epoch units* and *adu* stands for *Active Directory
  units*)
- the difference in seconds between the two starting times is
  $11644473600$.

I usually also account for both $0$ and $0x7fffffffffffffff$ (yes, it's
one $7$ followed by fifteen $f$-s) to yield a special `undef` because
they're often used to mark a special condition.

So, in a `perl` that supports 64-bit integers and some indulgence for
magic numbers:


```perl
sub adtime_to_epoch {
    return undef if $_[0] == 0 || $_[0] == 0x7fff_ffff_ffff_ffff;
    $_[0] / 10_000_000 - 11644473600;
}

sub epoch_to_adtime {
    defined $_[0] ? ($_[0] + 11644473600) * 10_000_000 : 0;
}

print scalar(gmtime adtime_to_epoch(shift)), "\n";
```

This seems to work fine with a time *thingie* from today:

```
$ perl /tmp/rt.pl 132891465010000000
Sat Feb 12 13:35:01 2022
```

So, future me... here you go.

Stay safe folks!




[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[accountExpires]: https://docs.microsoft.com/en-us/windows/win32/adschema/a-accountexpires
[greg]: https://en.wikipedia.org/wiki/Gregorian_calendar
[Unix epoch]: https://en.wikipedia.org/wiki/Unix_time
[gmtime]: https://perldoc.perl.org/functions/gmtime
[localtime]: https://perldoc.perl.org/functions/localtime
