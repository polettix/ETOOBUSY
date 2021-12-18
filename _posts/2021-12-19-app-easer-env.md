---
title: 'App::Easer smarter environment variables'
type: post
tags: [ perl, client, terminal ]
comment: true
date: 2021-12-19 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I recently released [App::Easer][] version 0.008.

After the introducing [App::Easer new defaults handling][], I was going
to start writing a tutorial (remember [Tutorials for modules][]?) and I
immediately hit a block.

In [App::Easer][], if you have an option (say `foo`) you can define many
ways to get its value, e.g. from command line options, the environment,
from files, as well as setting a default, like this:

```perl
{
    help        => 'the foo and the bar',
    getopt      => 'foo|f=s',
    environment => 'APP_FOO',
    default     => 'baz',
}
```

Fact is that, in my case, most of the times the environment variables
are set with a prefix tied to my application and a suffix tied to the
parameter name, in uppercase.

So I thought that *it would be so useful to have this out of the box!*

Which led me to wishing support for this interface too:

```perl
{
    help        => 'the foo and the bar',
    getopt      => 'foo|f=s',
    environment => 1,
    default     => 'baz',
},
{
    help        => 'the bar and stop',
    getopt      => 'bar|b=!',
    environment => 'WHATEVER_YOU_WANT',
    default     => 'galook',
}
```

That is:

- if key `environment` is set to value/string `1` (exactly) it means
  that the name of the environment variable should be generated
  automatically;

- otherwise it's just used out of the box (like in the case of option
  `bar` in the second example).

To get this behaviour... just set configuration variable
`auto-environment`.

This requires also the introduction of an additional configuration in
the `configuration` section, to set the `name` of the application, which
doubles down as the *prefix* used for generating environment variables
names:

```
my $app = {
    configuration => {
        'auto-environment' => 1,       # use the new feature
        name               => 'myapp', # prefix for env var names
        ...
    },
    commands => {
        MAIN => {
            options => [
                {
                    help        => 'the foo and the bar',
                    getopt      => 'foo|f=s',
                    environment => 1,
                    default     => 'baz',
                },
                ...
```

The example above would generate the environment variable name
`MYAPP_FOO`, as you can imagine.

So... every time I mess around using `App::Easer` I find some more
corners that should be ironed out... I'm not whether I like this or not!

[Perl]: https://www.perl.org/
[App::Easer]: https://metacpan.org/pod/App::Easer
[Feature creeping in App::Easer]: {{ '/2021/11/30/app-easer-feature-creeping/' | prepend: site.baseurl }}
[JSON]: https://www.json.org/
[App::Easer new defaults handling]: {{ '/2021/12/12/app-easer-defaults/' | prepend: site.baseurl }}
[Tutorials for modules]: {{ '/2021/11/29/tutorials-for-modules/' | prepend: site.baseurl }}
