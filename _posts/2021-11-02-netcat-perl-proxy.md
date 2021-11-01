---
title: 'Proxy setup for Netcat in Perl'
type: post
tags: [ perl, networking, linux ]
series: Netcat in Perl
comment: true
date: 2021-11-02 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Adding support for `CONNECT` setup in a Netcat for [Perl][].

In [Reinventing Netcat in Perl][] we saw a way of putting some code that
implements the basic functionality of Netcat in [Perl][].

Now it's time to look at the support for HTTP proxies that accept the
`CONNECT` method:

```perl
package IO::Flows::HttpProxy;
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use Exporter 'import';
our @EXPORT_OK = qw< proxy_CONNECT >;

sub _peer_socket ($hp) {
   my ($host, $port) = split m{:}mxs, $hp;
   require IO::Socket::INET;
   IO::Socket::INET->new(
      Proto => 'tcp',
      PeerAddr => $host,
      PeerPort => $port,
   ) or die "IO::Socket $!\n";
}

sub proxy_CONNECT ($proxy, $target, $credentials = undef) {
   state $CRLF = "\x{0d}\x{0a}";
   my $pxy = _peer_socket($proxy);

   my @request = (
      "CONNECT $target HTTP/1.1",
      "Host: $target",
   );
   if (defined $credentials) {
      require MIME::Base64;
      $credentials = MIME::Base64::encode_base64($credentials, '');
      push @request, "Proxy-Authorization: Basic $credentials";
   }

   my $flower = IO::Flows->new;
   my $sid = $flower->add_flow(
      {
         read => {fh => undef},
         write => {fh => $pxy, shutdown => 0},
         buffer => join($CRLF, @request, '', ''),
      }
   );
   my $rflow = {
      read => {fh => $pxy, shutdown => 0},
      write => {fh => undef},
      buffer => '',
   };
   my $rid = $flower->add_flow($rflow);
   while ('necessary') {
      $flower->spin or die "whatevah\n";
      $rflow->{buffer} =~ s{\A (.*?) (?-x:\x{0d}?\x{0a}\x{0d}?\x{0a}) }{}mxs or next;
      my $headers = $1;
      print {*STDERR} "HEADERS:\n>$headers<\n";
      return (
         {
            read => { fh => $pxy },
            buffer => $rflow->{buffer},
         },
         {
            write => { fh => $pxy },
            buffer => '',
         },
      );
   }
}

1;

package main;

my ($rpxy, $wpxy) = IO::Flows::HttpProxy::proxy_CONNECT(@ARGV);
my $flower = IO::Flows->new;
$flower->add_flow({$rpxy->%*, write => { fh => \*STDOUT }});
$flower->add_flow({$wpxy->%*, read  => { fh => \*STDIN  }});
1 while $flower->spin;
$flower->close_all;
```

The idea is to create the connection to the proxy and handle the initial
part where the *other* connection is setup. After that, we use
`IO::Flows` to revert to the *old* Netcat behaviour: connect the
standard I/O descriptors with the socket to the proxy.

Stay safe folks!

[Perl]: https://www.perl.org/
[Reinventing Netcat in Perl]: {{ '/2021/11/01/netcat-perl-2/' | prepend: site.baseurl }}
