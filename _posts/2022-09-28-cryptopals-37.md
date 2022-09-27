---
title: Cryptopals Diversion 3 - SRP server and client
type: post
tags: [ security, cryptography ]
series: Cryptopals
comment: true
date: 2022-09-28 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Preparing for [Challenge 37][] in [Cryptopals][].

The first part of this challenge is about re-using the code from the
previous one to build a real client and a real server:

> Get your SRP working in an actual client-server setting. "Log in" with
> a valid password using the protocol. 

This is only a preparation, of course.

# Server

Let's start with the server. File `SRPSession.pm` contains the base
class (exactly as in the previous post):

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use File::Basename 'dirname';
use lib dirname(__FILE__);

package SRPServerSession;
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use CryptoPals qw< random_octets >;
use parent 'SRPSession';

sub init ($self) {
   my $salt = $self->{salt} = random_octets(16);
   my $x_hex = $self->sha256_hex($salt, $self->{P});
   my $x = $self->hex2bigint($x_hex);
   my $v = $self->{v} = $self->modexp($self->{g}, $x, $self->{p});
   my $gb = $self->modexp($self->@{qw< g secret_key p>});
   $self->{public_key} = ($v * $self->{k} + $gb) % $self->{p};
   return $self;
}

sub fail_login { die "invalid login\n" }

sub login_phase1 ($self, $email, $client_public_key) {
   fail_login() unless $email eq $self->{I};
   $self->{client_pk} = $client_public_key;

   my $u_hex = $self->sha256_hex($client_public_key, $self->{public_key});
   my $u = $self->hex2bigint($u_hex);

   my $v_u = $self->modexp($self->{v}, $u, $self->{p});
   my $S = $self->{S} = $self->modexp($client_public_key * $v_u,
      $self->{secret_key}, $self->{p});
   $self->{K} = $self->sha256($S);
   return $self->@{qw< salt public_key >};
}

sub login_phase2 ($self, $authenticator) {
   my $expected = $self->hmac_sha256($self->@{qw< K salt >});
   say '<', unpack('H*', $expected), '>';
   return $expected eq $authenticator;
}

package main;
use Mojolicious::Lite '-signatures';
use CryptoPals ':all';
use Math::BigInt;

my $server = SRPServerSession->new(I => $ENV{EMAIL}, P => $ENV{PASSWORD});

get '/phase1' => sub ($c) {
   my $email = $c->param('email');
   my $cpk = Math::BigInt->from_hex($c->param('public_key'));
   my ($salt, $spk) = $server->login_phase1($email, $cpk);
   $salt = unpack 'H*', $salt;
   $spk = $spk->as_hex =~ s{\A 0x}{}irmxs;
   return $c->render(json => {salt => $salt, public_key => $spk});
};

get '/phase2' => sub ($c) {
   my $authenticator = pack 'H*', $c->param('authenticator');
   return $c->render(json => {status => 'OK'})
      if $server->login_phase2($authenticator);
   return $c->render(json => {status => 'ERROR'}, status => 401);
};

app->start;
```

The code in the server session class is unchanged. We're using
[Mojolicious][] to implement a server quickly, providing one endpoint
for each phase. The astute reader will have noted that the comparison
function in `login_phase2` is unsafe because we leverage the stock `eq`
operator, which probably short-circuits and leaks through time.
Whatever.

The functions realizing the controller take care of params
marshalling/unmarshalling (we're mostly sending out encoded stuff here)
but, apart from this, stick to the original.


# Client

Client time:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use File::Basename 'dirname';
use lib dirname(__FILE__);

package SRPClientSession;
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use parent 'SRPSession';

sub init ($self) {
   $self->{public_key} = $self->modexp($self->@{qw< g secret_key p>});
   return $self;
}

sub public_key ($self) { return $self->{public_key} }

sub email ($self) { return $self->{I} }

sub login_phase1 ($self) { return $self->@{qw< I public_key >} }

sub login_phase2 ($self, $salt, $server_public_key) {
   my $u_hex = $self->sha256_hex($self->{public_key}, $server_public_key);
   my $u = $self->hex2bigint($u_hex);
   my $x_hex = $self->sha256_hex($salt, $self->{P});
   my $x = $self->hex2bigint($x_hex);
   my $base = $self->{k} * $self->modexp($self->{g}, $x, $self->{p});
   $base = ($server_public_key - $base) % $self->{p};
   my $S = $self->{S} = $self->modexp($base,
      $self->{secret_key} + $u * $x, $self->{p});
   my $K = $self->{K} = $self->sha256($S);
   my $K_hex = unpack 'H*', $self->{K};
   return $self->hmac_sha256($K, $salt);
}

package main;
use v5.24;
use warnings;
use CryptoPals ':all';
use Mojo::UserAgent;
use Mojo::URL;
use Math::BigInt;

my ($email, $password, $base) = @ARGV;
$base //= 'http://localhost:3000';

my %args = (I => $email, P => $password);
my $client = SRPClientSession->new(%args);
my $ua = Mojo::UserAgent->new;

my ($cun, $cpk) = $client->login_phase1;
my $ph1_url = Mojo::URL->new("$base/phase1")->query(email => $cun,
   public_key => ($cpk->as_hex =~ s{\A 0x}{}irmxs));
my $res = $ua->get($ph1_url)->res;
my $ph1_data = $res->json;

my $salt = pack 'H*', $ph1_data->{salt};
my $spk  = Math::BigInt->from_hex($ph1_data->{public_key});

my $authenticator = unpack 'H*', $client->login_phase2($salt, $spk);
my $ph2_url = Mojo::URL->new("$base/phase2")->query(authenticator =>
   $authenticator);
$res = $ua->get($ph2_url)->res;
say $res->is_success ? q{we're in!} : 'no luck...';
```

The code in the class is the same as before. We're using
[Mojolicious][]'s excellent user agent class to query our server, as
well as a couple of calls to do marshalling/unmarshalling of the data.

Everything seems to be working:

```
$ perl 37-cnt.pl foo@bar.baz xxx
we're in!
```


Stay safe *and secure*!

[Perl]: https://www.perl.org/
[Cryptopals]: {{ '/2022/07/10/cryptopals/' | prepend: site.baseurl }}
[Challenge 37]: https://cryptopals.com/sets/5/challenges/37
[Mojolicious]: https://metacpan.org/pod/Mojolicious
