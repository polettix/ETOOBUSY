---
title: 'Reinventing Netcat in Perl'
type: post
tags: [ perl, networking, linux ]
comment: true
series: Netcat in Perl
date: 2021-11-01 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Playing towards a different Netcat in [Perl][].

[SALVA][]'s code we talked about in [Netcat... in Perl][] is excellent
but very closely tied to relate a TCP socket to the standard descriptors
for input and output.

Before discovering it I was already playing with the idea of doing
something similar, and decided to take *great* inspiration from that
code. In particular, setting the handles to be *non-blocking* comes from
there.

So, here's my transformation, which will enable adding support for
proxies:

```perl
package IO::Flows;
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use Fcntl qw(F_GETFL F_SETFL O_NONBLOCK);
use Errno qw(ENOTSOCK);
use constant MAXBUFSIZE => 64 * 1024;
use constant     TXSIZE => 16 * 1024;
use constant    TIMEOUT => 5;

sub new ($package, %opts) {
   my $flows = delete($opts{flows}) // [];
   my $self = bless {
      max_buffer_size => MAXBUFSIZE,
      transfer_size => TXSIZE,
      timeout => TIMEOUT,
      %opts,
      _flows => {},
      _count => 0,
   }, $package;
   $self->add_flow($_->@*) for $flows->@*;
   return $self;
}

sub add_flow ($self, $flow, $wh = undef) {
   state $id = 0;
   $flow = { read => { fh => $flow }, write => { fh => $wh } }
      if defined $wh;
   for my $ep ($flow->@{qw< read write >}) {
      if (defined(my $fh = $ep->{fh})) {
         fcntl($fh, F_SETFL, fcntl($fh, F_GETFL, 0) | O_NONBLOCK);
         binmode $fh;
         $ep->{active} = 1;
         $ep->{shutdown} = 1 unless exists $ep->{shutdown};
         $self->{_count}++;
      }
      else {
         $ep->{active} = 0;
      }
   }
   $flow->{buffer} = '' unless defined $flow->{buffer};
   $self->{_flows}{++$id} = $flow;
   return $id;
}

sub select ($self) {
   my $rb = my $wb = '';
   for my $flow (values $self->{_flows}->%*) {
      my $buf_size = length $flow->{buffer};
      vec($rb, fileno($flow->{read}{fh}), 1) = 1
         if $flow->{read}{active} && $buf_size < $self->{max_buffer_size};
      vec($wb, fileno($flow->{write}{fh}), 1) = 1
         if $flow->{write}{active} && $buf_size > 0;
   }
   my $n = select($rb, $wb, undef, $self->{timeout}) or return;
   return ($n, $rb, $wb);
}

sub spin ($self) {
   return unless $self->{_count} > 0;
   local $SIG{PIPE} = 'IGNORE';

   my ($n, $rb, $wb) = $self->select or return $self->{_count};

   for my $flow (values $self->{_flows}->%*) {
      if ($flow->{read}{active} && vec($rb, fileno($flow->{read}{fh}), 1)) {
         my $n_read = sysread $flow->{read}{fh}, $flow->{buffer},
            $self->{transfer_size}, length $flow->{buffer};
         if (! $n_read) { # eof
            $self->_shutdown($flow, 'read');
            $self->_shutdown($flow, 'write')
               unless length $flow->{buffer} > 0;
         }
      }
      if ($flow->{write}{active} && vec($wb, fileno($flow->{write}{fh}), 1)) {
         my $n_write = syswrite $flow->{write}{fh}, $flow->{buffer},
            $self->{transfer_size};
         if (! $n_write) {
            $self->_shutdown($flow, 'write');
            $self->_shutdown($flow, 'read') if $flow->{read}{active};
            $flow->{buffer} = '';
         }
         else {
            substr $flow->{buffer}, 0, $n_write, '';
            $self->_shutdown($flow, 'write')
               unless $flow->{read}{active} || length $flow->{buffer} > 0;
         }
      }
   }

   return $self->{_count};
}

sub _shutdown ($self, $flow, $endpoint) {
   my $section = $flow->{$endpoint};
   $section->{active} = 0;
   $self->{_count}--;
   return unless $section->{shutdown};
   return if shutdown($section->{fh}, ($endpoint eq 'read' ? 0 : 1));
   return close ($section->{fh}) if $! == ENOTSOCK;
   return;
}

sub close_all ($self) {
   my %done;
   for my $flow (values $self->{_flows}->%*) {
      for my $ep ($flow->@{qw< read write >}) {
         defined(my $fileno = fileno($ep->{fh})) or next;
         next if $done{$fileno}++;
         close $ep->{fh};
      }
   }
   return $self;
}

1;
```

It's a lot of code... the gist of it is that there are generic *flows*
with an input to read from, an output to write from, and a buffer in
between. [SALVA][]'s code inspired the limits about the buffer, as well
using `shutdown` to do the half-close.

Changing the approach like this will enable getting in the middle for
just the right amount of time to manage the setup of the connection...
but this will be something for another post.

Stay safe!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Netcat... in Perl]: {{ '/2021/10/31/netcat-in-perl/' | prepend: site.baseurl }}
[SALVA]: https://metacpan.org/author/SALVA
