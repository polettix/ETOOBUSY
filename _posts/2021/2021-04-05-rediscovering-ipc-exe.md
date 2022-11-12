---
title: 'Rediscovering IPC::Exe'
type: post
tags: [ perl, cpan ]
comment: true
date: 2021-04-05 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I recently rediscovered [IPC::Exe][].

In a previous post ([IPC::Cmd considered harmful][]) I talked about my
hurdles with using the CORE module `IPC::Cmd` and how I was surprised about
its behaviour. It even got some [attention in Reddit][reddit] (which,
incidentally, makes me wonder whether I should ditch the Disqus commenting
completely, given that nobody seems to use it).

In that post I also shared a few alternatives, like [IPC::Run][] which I
eventually selected for the problem I had at the time.

Then I recently had to do the [Crypt::LE update][] and I re-discovered a
host of small utilities (e.g. the program described in 
[Send notifications through Mailgun with HTTP::Tiny][]), including one where
I used [IPC::Exe][].

From the [NAME][] section:

> Execute processes or Perl subroutines & string them via IPC. Think shell pipes.

The interface is a bit *complicated*, but at the end of the day
[IPC::Run][]'s interface is not simple anyway.

Additionally, there's a lot of attention regarding the redirection of
*output* streams:

```
"2>#"  or "2>null"   silence  stderr
 ">#"  or "1>null"   silence  stdout
"2>&1"               redirect stderr to  stdout
"1>&2" or ">&2"      redirect stdout to  stderr
"2>&-"               close    stderr
"1><2" or "2><1"     swap     stdout and stderr
                     (+) shell-way works too:
                         \"3>&1", \"1>&2", \"2>&3", \"3>&-"
```

but little to no mention about standard input, which was my real interest at
the time (and, looking at the code, I solved in an overcomplicated way).
Spoiler alert, if you just want to close the first process's standard input,
just pass `'\</dev/null'`.

As an example, let's re-create the program to get the expiration date of a
TLS certificate, driving it all from [Perl][]:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use IPC::Exe 'exe';
use Date::Parse 'str2time';
use POSIX 'strftime';

my $epoch = str2time(certificate_expiration_date(shift // 'example.com'));
say strftime('%Y-%m-%dT%H:%M:%SZ', gmtime($epoch));

sub certificate_expiration_date ($target) {
   my ($domain, $port) = split m{:}, $target;
   $target = $domain . ':' . ($port || 443);

   my @parts = &{
      exe qw< openssl s_client -connect >, $target, -servername => $domain,
         \'</dev/null', \'2>/dev/null',
      exe + {stdout => 1}, qw< openssl x509 -noout -enddate >,
   };
   $_ || die "pipe unsuccessful\n" for @parts;
   defined(my $line = readline $parts[-1])
      or die "cannot read from pipeline: $!\n";
   return $line =~ s{.*=}{}rmxs;
}
```

The pipeline of two `openssl` commands is implemented with two calls to
`exe`; the first one contains two redirections:

- one for standard input, so that `s_client` will not wait for inputs;
- one for standard error, to avoid printing too much stuff in output.

The expression `&{ ... }` is put because the whole `exe` chaining returns a
*reference to a sub*, which must be invoked to make the magic happen. We
might just as well do something like this:

```perl
my $sub = exe .... exe ... exe ...;
$sub->();
```

but maybe it's clunkier. I don't know.

So there you have it, another arrow that might come handy in some specific
scenario!

[IPC::Exe]: https://metacpan.org/pod/IPC::Exe
[IPC::Cmd considered harmful]: {{ '/2021/02/27/ipc-cmd-considered-harmful/' | prepend: site.baseurl }}
[reddit]: https://www.reddit.com/r/perl/comments/lu39cy/ipccmd_considered_harmful/
[IPC::Run]: https://metacpan.org/pod/IPC::Run
[Crypt::LE update]: {{ '/2021/03/29/crypt-le-update/' | prepend: site.baseurl }}
[Send notifications through Mailgun with HTTP::Tiny]: {{ '/2021/04/02/mailgun' | prepend: site.baseurl }}
[NAME]: https://metacpan.org/pod/release/GLAI/IPC-Exe-2.002001/lib/IPC/Exe.pm#NAME
[Perl]: https://www.perl.org/
