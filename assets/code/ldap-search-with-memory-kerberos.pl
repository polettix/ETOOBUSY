#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use Scalar::Util 'blessed';

use Path::Tiny;
use Ouch ':trytiny_var';
use Try::Catch;

use Authen::Krb5;
use Authen::SASL;
use Net::LDAP;

use constant PRINT_ENTRIES => 5;

my $username = 'admin';
my $realm    = 'DEMO1.FREEIPA.ORG';
my $host     = 'ipa.demo1.freeipa.org';

my $conf_file = path('.')->child('krb5.conf');
$conf_file->spew(<<'END');
[libdefaults]
dns_canonicalize_hostname = false
default_ccache_name = MEMORY
END
$ENV{KRB5_CONFIG} = $conf_file->absolute->stringify;

exit try {
   my $cache = acquire_TGT("$username\@$realm", 'Secret123');

   say 'first call, this should return a bunch of entries:';
   LDAP_search($host, $username);

   say q<now let's get rid of the credentials in the cache>;
   $cache->destroy;

   say 'second call, this should fail for lack of credentials';
   try { LDAP_search($host, $username) }
   catch {
      if (bleep($_) =~ m{No Kerberos credentials available}i) {
         say '   --> failed as expected!';
      }
      else {
         say '   "bad" failure:', bleep($_);
      }
   };

   0;
}
catch {
   warn bleep($_);
   1;
};

sub LDAP_search ($host, $dn, $base= '', $filter = '(objectClass=*)') {
   my $ldap = Net::LDAP->new($host)
      or ouch 500, "LDAP: $@\n";
   my $sasl = Authen::SASL->new(mechanism => 'GSSAPI');
   my $msg = $ldap->bind($dn, sasl => $sasl, version => 3);
   ouch 500, join ' ', 'bind error', $msg->error, $sasl->error
      if $msg->code != 0;
   $msg = $ldap->search(base => '', filter => '(objectClass=*)');
   ouch 500, join ' ', 'search error', $msg->error if $msg->code != 0;
   my @entries = $msg->entries;
   if (@entries <= PRINT_ENTRIES) {
      say '- ', $_->dn for @entries;
   }
   else {
      say '- ', $_->dn for @entries[0 .. (PRINT_ENTRIES - 2)];
      my $n_residual = @entries - PRINT_ENTRIES + 1;
      say ". (and other $n_residual entries...)";
   }
}

sub acquire_TGT ($principal, $password) {
   return try {
      Authen::Krb5::init_context() or die;
      $principal = Authen::Krb5::parse_name($principal) or die;
      my $cache = Authen::Krb5::cc_resolve('MEMORY') or die;
      $cache->initialize($principal) or die;
      my $credentials = Authen::Krb5::get_init_creds_password(
         $principal, $password) or die;
      $cache->store_cred($credentials) or die;
      $cache;
   }
   catch {
      die $_ if blessed($_) && $_->isa('Ouch');
      ouch 500, Authen::Krb5::error();
   }
}
