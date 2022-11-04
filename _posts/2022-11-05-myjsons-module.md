---
title: 'WebService::MyJSONs'
type: post
tags: [ perl, coding, module ]
comment: true
date: 2022-11-05 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> New module: [WebService::MyJSONs][].

Well, there's really little to add. The implementation is faithful to
[A possible SYNOPSIS for a MyJSONs module][synopsis].

It's possible to install the module from the [Codeberg repository][]
directly as an executable in `PATH`:

```shell
curl -Lo myjsons https://codeberg.org/polettix/WebService-MyJSONs/raw/branch/main/lib/WebService/MyJSONs.pm
chmod +x myjsons
# mv myjsons ~/bin
```

The last line is commented out, in case it's better to put the program
somewhere else in `PATH`.

There's virtually no test - the only one just checks that the module
compiles. I'm trying to think whether I should condition the execution
of some tests to the definition of an environment variable's value or
so, I don't like stuff that *phones home*.

Stay safe!

[Perl]: https://www.perl.org/
[WebService::MyJSONs]: https://metacpan.org/pod/WebService::MyJSONs
[synopsis]: {{ '/2022/11/02/myjsons-module-synopsis/' | prepend: site.baseurl }}
[Codeberg repository]: https://codeberg.org/polettix/WebService-MyJSONs
