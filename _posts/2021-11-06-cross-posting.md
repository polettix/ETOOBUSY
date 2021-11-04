---
title: 'Cross-posting considered harmful?'
type: post
tags: [ internet, rant ]
comment: true
date: 2021-11-06 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Ask in the right place first, or die tryin'


The documentation for option `ChrootDirectory` in [OpenSSH][] has this:

> For safety, it is very important that the directory hierarchy be
> prevented from modification by other processes on the system
> (especially those outside the jail). Misconfiguration can lead to
> unsafe environments which sshd(8) cannot detect.

While I undertand the general invitation to consider every situation
carefully, the first part seems quite prescriptive so I was wondering if
there's anything that I'm *obviously* missing.

So, a few days ago I opened a question on [Server Fault][]:
[OpenSSH ChrootDirectory man page remark on safety][].

User [Paul][] was kind on providing a view, but I feel it's actually
making my point instead: it can be OK for other processes outside the
jail to do the modifications, as long as the correct things are
addressed. Which left me with the same feeling as before, i.e. the
possibility that I might be missing something.

At this point, I figured that this question was probably better
addressed by security experts than administration experts. So, after
about a week, I posted the same question in [Information Security][],
pointing to the original question too.

The [new question][] was closed as **off-topic** and the only explicit
reason I saw was this:

> I’m voting to close this question because it is cross-posted

(Not exactly welcoming to a new user, but whatever).

This left me quite frustrated: first, I think it's much more *on-topic*
in [Information Security][] than in [Server Fault][]; second, I'll have
to look elsewhere for some insight (which would have been useful in
[Information Security][] anyway).

Lesson learned: ask in the right place first, or die tryin' 🤐

[Server Fault]: https://serverfault.com/
[OpenSSH ChrootDirectory man page remark on safety]: https://serverfault.com/questions/1081539/openssh-chrootdirectory-man-page-remark-on-safety
[Paul]: https://serverfault.com/users/153188/paul
[Information Security]: https://security.stackexchange.com/
[new question]: https://security.stackexchange.com/questions/256641/openssh-chrootdirectory-man-page-remark-on-safety
[OpenSSH]: https://www.openssh.com/
