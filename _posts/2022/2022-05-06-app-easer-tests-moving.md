---
title: 'App::Easer - moving ahead with tests'
type: post
tags: [ perl, terminal, client ]
comment: true
date: 2022-05-06 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I added tests for options precedence to [App::Easer][] V2.

I'm moving slowly with [App::Easer][] but at least I'm moving. I added
[some tests][] that seem to show that everything is going fine with the
separation between the ordering of options inside the `sources`
arrayref, the precedence and their default overlapping.

Although I'm not showing the `test_run` implementation here, I hope this
makes it clear that it's indeed possible to make environment variables
take precedence over command line ones:

```perl
# subvert precedence, make environment win over command-line
subtest 'parent, Environment over CmdLine' => sub {

   # input arguments for the test run
   my @args = qw< --one cmdline-one --four cmdline-four >;

   # input environment for the test run
   my %env = (
      ONE => 'environment-one',
      TWO => 'environment-two',
      FIVE => 'environment-five',
   );

   # expected output parsed configuration after the test run
   my %conf = (
      one => 'environment-one',
      two => 'environment-two',
      three => 'three',           # default
      four => 'cmdline-four',
      five => 'environment-five',
   );

   # temporarily override the list of sources and their precedences
   my $save_sources = $app->{sources};
   $app->{sources} = [qw< +CmdLine +Environment=5 +Default=100 >];

   # run the test
   test_run($app, \@args, \%env, 'parent')
      ->no_exceptions
      ->conf_is(\%conf);

   # restore original sources
   $app->{sources} = $save_sources;
};
```

As it is, `+CmdLine` is assigned precedence value 10, so `+Environment`
gets to go first because it has a lower value. `+Default` still gets
last with its meager 100th precedence.

This is something that I never adopted so far, but I've seen a use case
in a module (something that had to do with databases or emails, I don't
remember precisely right now) where the precedence to the environment
was advertised as a feature so that test runs could be easier. I guess
it mostly boils down on how one organizes their own shell scripts,
anyway.

I'm definitely out of time with respect to [suggestion][] #2 by [Damian
Conway][]: *Write the Test Cases Before the Code*. Better late than
never, I guess.

Stay safe and testy!



[Perl]: https://www.perl.org/
[App::Easer]: https://github.com/polettix/App-Easer/
[some tests]: https://github.com/polettix/App-Easer/blob/e6ae62d9fb8a8d40e951881a253c7aa88cb3baa5/t/V2/21.options-ordering.t
[Damian Conway]: https://www.perl.com/pub/2005/07/14/bestpractices.html/#author-bio-damian-conway
[suggestion]: https://www.perl.com/pub/2005/07/14/bestpractices.html/
