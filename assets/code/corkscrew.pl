#!/usr/bin/env perl

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
         warn "sysread(): $!\n" unless defined $n_read;
         if (! $n_read) { # error or eof... close stuff
            $self->_shutdown($flow, 'read');
            $self->_shutdown($flow, 'write')
               unless length $flow->{buffer} > 0;
         }
      }
      if ($flow->{write}{active} && vec($wb, fileno($flow->{write}{fh}), 1)) {
         my $n_write = syswrite $flow->{write}{fh}, $flow->{buffer},
            $self->{transfer_size};
         warn "syswrite(): $!\n" unless defined $n_write;
         if (! $n_write) { # error or whatever... close stuff
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