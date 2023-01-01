---
title: 'App::Easer validations'
type: post
tags: [ perl, client, terminal ]
series: 'App::Easer'
comment: true
date: 2022-07-16 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Fixing the validation gap in [App::Easer][].

You know when you do a lot of work, then you see a tiny-teensy amount of
dust and there's a rug just about 5 centimeters apart? *Surely nobody
will noooootice...*

And then *they noticed*: [RFE: Allow code refs as values in hash passed
to params\_validate][issue].

Well, jokes apart, I'm grateful to [djerius][] for bringing the topic
up, because I sort of remember that I actually wanted to do things the
way they asked.

The gist of the issue lies in the fact that [App::Easer][] tries to NOT
impose a view on how the hierarchical application should be coded. Want
to code a little application, avoid OO and use a hash? Be our guest!
Want to structure the application with a hierarchy of classes in
modules? Come in and relax, you're in the right place!

So, of course, it's imperative that whatever is available with OO
sub-classing is available in the *hash-based* interface as well. Which
is not the case for `validate`, today.

Well, for not much more I hope, as the [CPAN Testers][] numbers for
[trial release 2.003][trial] seem promising:

![CPAN Testers for 2.003]({{ '/assets/images/app-easer-2.003.png' | prepend: site.baseurl }})

This also gave me a prod to write some basic tests regarding validation,
discover a bug in how I was using [Params::Validate][] (which I still
don't understand why it was a bug, anyway) and write some documentation.

Thanks [djerius][], and have a nice safe day everybody!

[Perl]: https://www.perl.org/
[App::Easer]: https://metacpan.org/pod/App::Easer
[issue]: https://github.com/polettix/App-Easer/issues/3
[djerius]: https://github.com/djerius
[CPAN Testers]: https://www.cpantesters.org/
[trial]: https://metacpan.org/release/POLETTIX/App-Easer-2.003-TRIAL
[Params::Validate]: https://metacpan.org/pod/Params::Validate
