---
title: 'OpenSSH Server: ChrootDirectory'
type: post
tags: [ OpenSSH, security ]
comment: true
date: 2021-10-26 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Some notes on the `ChrootDirectory` directive for [OpenSSH][].

From the documentation in my system:

> Specifies the pathname of a directory to chroot(2) to after
> authentication.  At session startup sshd(8) checks that all com‐
> ponents of the pathname are root-owned directories which are not
> writable by any other user or group.

This can be a bit annyoing, because I was expecting to be able and force
a user to be allowed into a *writeable* directory, expecially because my
main target is to pair this with an SFTP-only setup (see [Setting up an
SFTP server][] for the details).

Alas, this is not possible, to a common workaround is to create a
writeable directory *inside* the directory indicated with
`ChrootDirectory` and let the user write things there.

> After the chroot, sshd(8) changes the working directory to the user's
> home directory.

I can only guess that after the `chroot` there's still a reference to
the *old* filesystem view, which is a leak. So `sshd` does the directory
change to be sure to land inside the *new* filesystem view.

> Arguments to `ChrootDirectory` accept the tokens described in the
> `TOKENS` section.

This means that it's possible to use a few `%` placeholder to make the
path a bit more generic than a single directory. As an example, `%u` is
replaced by the username and `%h` by the path to their home directory
(even though this would have the restriction describe above, so it's
usually not a viable option). Should we need a literal `%` character,
it's `%%`.

> The ChrootDirectory must contain the necessary files and directories
> to support the user's session.  For an interactive session this
> requires at least a shell, typically sh(1), and basic /dev nodes such
> as null(4), zero(4), stdin(4), stdout(4), stderr(4), and tty(4)
> devices.

After the `chroot`, the filesystem view provided to users is restricted
to that directory only, hence they will generally lack a lot of the
things that would be needed to login with a functional shell. Note that
adding the shell might imply the need to also provide the shared
libraries it relies upon, unless of course it's compiled statically.


> For file transfer sessions using SFTP no additional configuration of
> the environment is necessary if the in-process sftp-server is used,
> though sessions which use logging may require /dev/log inside the
> chroot directory on some operating systems (see sftp-server(8) for
> details).

Apart from the indication about logging, it's worth remembering that
the in-process sftp-server can be enabled with the following
configuration:

```
Subsystem sftp internal-sftp
```

Otherwise... it would either not be configured, or point to an external
program that MUST be found in the new chroot-ed filesystem (this is
pretty much the same situation discussed for the shell above).

> For safety, it is very important that the directory hierarchy be
> prevented from modification by other processes on the system
> (especially those outside the jail).  Misconfiguration can lead
> to unsafe environments which sshd(8) cannot detect.

While I understand the general gist of this warning (e.g. someone might
bind-mount stuff inside and open the flood gates), I'm not sure I
understand the danger that might come if an external process decides to
add some files in that directory. Any light in this direction would be
much appreciated!

> The default is `none`, indicating not to chroot(2).

This pretty much seals the documentation, and makes sense as a default
because anything else would mean that the administrator has to ensure
the proper setup of the filesystem, which is usually not needed in the
general case.

I guess it's everything... future me!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[OpenSSH]: https://www.openssh.com/
[Setting up an SFTP server]: {{ '/2021/10/25/sshd-for-sftp/' | prepend: site.baseurl }}
