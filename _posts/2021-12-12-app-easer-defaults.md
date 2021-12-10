---
title: 'App::Easer new defaults handling'
type: post
tags: [ perl, client, terminal ]
comment: true
date: 2021-12-12 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> An update to [App::Easer][] for smarter handling of default values.

It's no mistery that there's some ongoing [Feature creeping in
App::Easer][] but whatever, it's a module to *do what I mean* and I can
mean a lot of things.

Sometimes of *mean* things, I mean.

The legacy way in which [App::Easer][] was handling *defaults* in the
collection of options was to put the associated handler `+Default` at
the end of the list of sources:

```
+CmdLine +Environment +Parent +Default
```

This basically meant that *command line options* take the precedence
over everything, then come environment variables, then a configuration
that might be inherited from some *parent* command (i.e. a partial
sub-command that appeared previously in the hierarchy) and, finally, the
default values.

This meant that the merging of the resulting hashes was as simple as
this:

```
sub hash_merge {
   return {map { $_->%* } reverse @_};
}
```

Alas, this served me well but... *not perfectly*.

One common option I like to add is a `--config|-c` that takes the path
to a file (usually a [JSON][] file) with additional configurations. This
is so handy for me that it's possible to set the `sources` configuration
to have this out of the box:

```
...
sources => '+SourcesWitFiles', # includes +JsonFileFromConfig
...
```

As you are probably guessing, this is a pre-arranged collection that
includes `+JsonFileFromConfig` which does exactly what I was describing
above. The exact sequence from `+SourcesWithFiles` was the following:

```
+CmdLine +Environment +Parent +JsonFileFromConfig +JsonFiles +Default
```

One drawback with this setup is that it's not possible to set a
*default* configuration file, because the `+Default` is considered only
*after* having attempted to loade the JSON file from option `config`.
For this to work, we would need to somehow *move* the defaults before in
the pipeline, but this would then make them less... *defaulty*.

In a first solution I decided to add *another* class of *higher
precedence* defaults (so-called "hi-defaults") to insert stuff in the
right place. I eventually landed on a different approach though: *make
defaults appear at the beginning of the options collection, while
marking them as **overridable***. This would make their values available
since the very beginning, while still allowing sources further down the
road to influence the specific values of all options.

To do this, three changes were needed:

- the *bundles* of `source`s were changed to move `+Default` at the
  beginning:

```
# +DefaultSources
+Default +CmdLine +Environment +Parent 

# +SourcesWithFiles
+Default +CmdLine +Environment +Parent
```

- the default handler for `+Default` was changed to *mark* all collected
  values, by setting their respective key with a fixed prefix `//=`- So,
  for example, key `foo` is turned into `//=foo`;

- function `hash_merge` was implemented like this:

```perl

sub hash_merge {
   my (%retval, %is_overridable);
   for my $href (@_) {
      for my $src_key (keys $href->%*) {
         my $dst_key = $src_key;
         my $this_overridable;
         if ($dst_key =~ m{\A //= (.*) \z}mxs) { # overridable
            $dst_key = $1;
            $is_overridable{$dst_key} = 1 unless exists $retval{$dst_key};
            $this_overridable = 1;
         }
         $retval{$dst_key} = $href->{$src_key}
            if $is_overridable{$dst_key} || ! exists($retval{$dst_key});
         $is_overridable{$dst_key} = 0 unless $this_overridable;
      }
   }
   return \%retval;
   # was a simple: return {map { $_->%* } reverse @_};
}
```

In practice, a default value `foo` is collected as `//=foo` and
`hash_merge` takes its value until some other value sets it. This makes
it possible to move the group at the beginning while still considering
its items... *defaults*.

I think it's everything for today, stay safe!

[Perl]: https://www.perl.org/
[App::Easer]: https://metacpan.org/pod/App::Easer
[Feature creeping in App::Easer]: {{ '/2021/11/30/app-easer-feature-creeping/' | prepend: site.baseurl }}
[JSON]: https://www.json.org/
