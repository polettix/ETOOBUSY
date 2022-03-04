---
title: Blurry (Microsoft) Teams
type: post
tags: [ software ]
comment: true
date: 2022-03-04 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I finally found a solution to a problem in Microsoft Teams.

At `$work` we use Microsoft Teams and all was going well until some time
ago it started performing **very** bad in the quality of incoming shared
content. That is, video from cameras of meetings participants was OK,
but anything shared from their computers (e.g. Excel spreadsheets) was
absolutely not readable.

The bad things when this kind of things happen it that a **lot** of the
suggestions that you find around are about the bandwidth. Well, of
course that is one cause, but *come on*.

There are three advices that I've found around that might be useful if
you're pretty sure you don't have bandwidth problems.

The first is to disable GPU acceleration from Teams configuration (it's
in the *General* group). That worked *a tiny teensy bit* but still I
couldn't read a thing. Other people's mileage may vary, so I suggest you
try this first as it's pretty simple to do. You can read about it e.g.
[here][gpu].

More recently I hit [this page][] with two additional advices:

- [get rid of Teams cache directory][cache] `%appdata%\Microsoft`. This
  makes sense as I guess that there's a lot of hidden browser stuff
  underneath, and too often cached stuff can cause problems. In my case,
  though, this didn't solve the problem.

- Run the program in **Compatibility mode** (for Windows 8, in my case).
  This finally made my day!

![Run Teams in compatibility mode]({{ '/assets/images/blurry-teams-didi.png' | prepend: site.baseurl }})

So thanks [\[Didi\]][didi], Independent Advisor, for solving my problem!

[gpu]: https://answers.microsoft.com/en-us/msteams/forum/all/blurry-on-microsoft-teams/51b7cd31-56cb-40cf-ba19-36f31552f332
[this page]: https://answers.microsoft.com/en-us/msteams/forum/all/blurry-files-when-shared-via-team/e1147219-0c0d-4aff-aba0-81e3f6e91e17
[cache]: https://www.uvm.edu/it/kb/article/clearing-teams-cache/
[didi]: https://answers.microsoft.com/en-us/profile/4bef65d4-4217-4bf7-be3d-da061f2ca331
