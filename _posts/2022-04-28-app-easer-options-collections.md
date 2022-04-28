---
title: 'App::Easer options collection'
type: post
tags: [ perl, client, terminal ]
comment: true
date: 2022-04-28 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Some reflections on evolving the options collection in [App::Easer][]
> V2.

Today (which is some days ago, actually) I had one of those *A-ha!*
moments of looking at the obvious and seeing it as such.

[App::Easer][] is, at the end of the day, a way of collecting options in
the most straightforward and easy way. Well, yes, there's the aspect of
organizing commands in sub-commands; but surely the most delicate thing
is about collecting options.

- *defaults*, possibly directly from where options are defined;
- the *command line*, of course
- the *environment*, which allows us setting stuff easily and durably
- *configuration files*, either provided explicitly or in some *known
  locations*
- anything else... a key-value store somewhere? Kubernetes ConfigMaps or
  Secrets maybe?

And more:

- *parents*: what should sub-commands see of options coming from parent
  commands?
- *sub-trees*: how about a single configuration file for a multi-leveled
  application?

There's a lot of possible sources, so the next question is: *how to
assemble them*? Which wins over which?

> Then there's another big question, of course: what if two sources
> provide values for multi-valued options? Merge them? Override? Give
> options about what to do? What if they have different types (like
> arrays and hashes)?

My little tiny epiphany was about the fact that *gathering* data is a
separate process from *merging* data. There you have it, I said it was
obvious.

In my case, I somehow coalesced the two, by using the ordering of
`sources` in a command's specification. Whatever comes first gets the
precedence over what comes after. This is very anti-hashy behaviour
(when we merge hashes straight away, the last to come takes it all), but
it's OK. Anyway, the ordering was used for both *gathering* options and
*merging* them, right? First come, first served.

Then I hit a little roadblock in the management of a chicken-and-egg
problem on using an option to set the path to a configuration file, and
setting a *default* value for that option (i.e. a default configuration
file name/path). I could not put the *default* at the beginning, because
they would not be defaults any more. On the other hand, I could not put
them last, because otherwise I would not have any file name for loading
the configuration at all.

This led me to implement a trick to put source `Default` at the
beginning, while still making those options appear as totally
overridable (I won't get into the details, see [here][here1] and
[here][here2] for more). Still, it feels like a hack-around.

Some other stuff I'm introducing led me to think that I should probably
separate gathering and merging in a saner way, allowing me to define the
order of gathering with the natural arrangement of `sources`, while
still allowing a flexible way to do merging. I'll probably add a
*priority* optional attribute to the source specification, with some
sane (by my point of view) default, i.e. something like this (the lower
the number, the earlier it is in the line to get considered for
providing a value):

```
+CmdLine=10
+Environment=20
+Parent=30
+Default=100
+JsonFileFromConfig=50
+JsonFiles=60
+FromTrail=40
```

The `JsonFileFromConfig` is taking options from a JSON file whose path
is provided as a configuration option itself; `JsonFiles` are other
configuration files that might have been set in *known locations*.

`FromTrail` is to allow setting configurations for a sub-command inside
a configuration file that is set at the overall level. This would allow
having a *single* configuration file for the whole application, with
some hierarchy that allows taking a part of it where needed, e.g.:

```json
"foo": "bar",
"sub-commands": {
    "baz": {
        "option1": "value2",
        "option3": "value4"
    }
}
```

This is another case where the order of gathering stuff clashes with
priority: surely I want to have all files loaded to use this
possibility, but want stuff from there to override a lot of stuff.

So well, this is probably where I'll head to.

Stay safe!


[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[App::Easer]: https://metacpan.org/pod/App::Easer
[here1]: https://github.com/polettix/App-Easer/blob/versioning/lib/App/Easer/V2.pm#L290
[here2]: https://github.com/polettix/App-Easer/blob/versioning/lib/App/Easer/V2.pm#L203
