---
title: Parsing emails
type: post
tags: [ perl ]
comment: true
date: 2023-07-10 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [MIME::Parser][] and [Email::Address::XS][] came to help.

I wanted to analyze an email and, in particular, I wanted to extract the
full list of recipients. As a *list*, I mean.

My inners self let a little *groan* come out: there's a plethora of
email-related modules in CPAN, many (most?) of which are from the same
author and fill different niches with different interfaces, in a quest for
the perfect one.

Don't get me wrong, I admire [RJBS][] and I also resonate with that kind of
quest for something that I would have liked to have already found there.

Still, there's a plethora of modules, and so my *groan*.

Luckily enough, some *13 years* ago I wrote a small reference booklet (still
available [here][]) about implementing several *clients for the web* in
[Perl][]. Did I mention that it's in Italian? No? Well, sorry for the wasted
bandwidth, folks.

> I will not apologize to Italian-understanding people though, I was clear
> that the book is from 13 years ago and much of it became obsolete.

So it kind of stuck with me that *parsing* emails could be done with
[MIME::Parser][]. Having the email saved as a file (according to RFC 2822,
not the proprietary formats that serve to wall gardens), this is what I
resorted to (more or less, I go by memory):

```perl
use MIME::Parser;
my $parser = MIME::Parser->new;   # get a parser
$parser->output_to_core(1);       # message is small enough

my $filename = shift(@ARGV);
open my $fh, '<:raw', $filename   # 3-args open for the win!
    or die "open('$filename'): $!";
my $email = $parser->parse($fh);  # gives a MIME::Entity object back
my $headers = $email->head;       # gives a MIME::Head object back
```

OK, now I only have to extract the recipients, which can appear either in
`to` or `cc`:

```perl
# don't copy-paste this, there's something better ahead
my @recipients = ($headers->get_all('to'), $headers->get_all('cc'));
```

Only thing is that... the `get`/`get_all` methods give back the *literal
string* the header is set to, not the nice list of addresses I was looking
for.

Fair enough, so what can we use for that? The list can be broken on multiple
lines and parsing addresses is not exactly easy.

Enter [Email::Address::XS][], which has the right tool for this particular
job:

```perl
# still not what I was looking for, but might be good for others
use Email::Address::XS 'parse_email_addresses';
my @recipients =
    map { parse_email_addresses($_) }
    map { $headers->get_all($_)     }
    qw< to cc >;
```

In my case, this was not the definitive solution, because I was collecting
results to print out a JSON-encoded string, so having objects of class
[Email::Address::XS][] was not *exactly* what I was after.

This was (or, well, the *tested* version of this):

```perl
use Email::Address::XS 'parse_email_addresses';
my @recipients =
    map { $_->as_string             } # $_->address -> foo@example.com
    map { parse_email_addresses($_) }
    map { $headers->get_all($_)     }
    qw< to cc >;
```

So there you go, future me: if you ever need this again, please assemble a
full program to share with *even-more-future-us* 🙄

Everybody else stay safe!

[Perl]: https://www.perl.org/
[MIME::Parser]: https://metacpan.org/pod/MIME::Parser
[Email::Address::XS]: https://metacpan.org/pod/Email::Address::XS
[RJBS]: https://metacpan.org/author/RJBS
[here]: http://polettix.s3.amazonaws.com/tmp/pwc.tar.gz 
