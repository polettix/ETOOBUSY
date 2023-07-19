---
title: LDAP groups expansion
type: post
tags: [ ldap, perl ]
comment: true
date: 2023-07-19 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A routine to expand groups from LDAP data.

Every now and then I have to figh**AHEM***play* with data from a LDAP
directory.

It so happened that I got some groups back, with a mixed compositions of
objects inside, namely `person` items intermixed with `group` ones. As stuff
propagates (like permission, or just plain inclusion), I was interested into
figuring out *all* items of class `person` that were eventually involved in
my initial group.

This is a problem that *cries* recursion, with the obvious caveat that
nothing prevents people to put some circular dependency inside, which we
have to beware of. Apart from this, anyway, it's been fun.

The code below summarizes my efforts. The whole LDAP retrieval is
encapsulated in a callback function, because I'm just playing and I don't
have a LDAP directory to test against.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

use JSON::PP 'decode_json';
use List::Util 'uniqstr';

my $tree = expand_tree(
      id => 'group4',
      id => 'group1',
      is_expandable => sub ($dn) { $dn =~ m{group}mxs },
      is_expandable => sub ($dn) { 1  },
      retrieve => \&example_provider,
   );

say encode_json(usort(collect_leaves($tree)));

sub encode_json ($data) {
   state $enc = JSON::PP->new->ascii->canonical->pretty;
   return $enc->encode($data);
}

sub is_group ($record) {
   my $oc = $record->{objectClass} // [];
   return scalar grep { $_ eq 'group' } (ref($oc) ? $oc->@* : $oc);
}

# %args holds key/value pairs, with the following keys:
# - id: the identifier of the entry point, either CN or distinguishedName
# - is_expandable: sub ref accepting a distinguishedName and returning
#                  whether it supports expansion or not
# - retrieve: sub ref to retrieve elements, by cn or distinguishedName
sub expand_tree (%args) {
   my $dn = $args{id};
   if ($dn !~ m{\A cn= }imxs) {
      my ($record) = $args{retrieve}->($dn);
      $dn = $record->{distinguishedName};
   }

   my %expanded;
   return sub ($inputs) {
      my (@items, @subs);
      for my $dn (ref($inputs) ? $inputs->@* : $inputs) {
         if ($args{is_expandable}->($dn)) {
            push @subs, $dn;
         }
         else {
            push @items, $dn;
         }
      }

      push @items, map {
         my $value = my $dn = $_->{distinguishedName};
         if (is_group($_)) {
            $value = { name => $dn };
            $value->{items} = __SUB__->($_->{member})
               unless $expanded{$dn}++;
         }
         $value;
      } $args{retrieve}->(@subs);

      return \@items;
   }->($dn);
}

sub collect_leaves ($tree) {
   return [ map { ref($_) ? __SUB__->($_->{items})->@* : $_ } $tree->@* ];
}

sub collect_leaves_unique ($tree) { usort(collect_leaves($tree)) }

sub collect_all ($tree) {
   return [
      map {
         ref($_) ? ($_->{name}, __SUB__->($_->{items})->@*) : $_
      } $tree->@*
   ];
}

sub collect_all_unique ($tree) { return usort(collect_all($tree)) }

sub usort ($aref) { [ uniqstr sort { $a cmp $b } $aref->@* ] }

sub example_provider (@requests) {
   state $data = [
      {
         objectClass => [ qw< top group > ],
         distinguishedName => 'CN=group1,OU=whatever',
         cn => 'group1',
         member => 'CN=group2,OU=whatever',
      },
      {
         objectClass => [ qw< top group > ],
         distinguishedName => 'CN=group2,OU=whatever',
         cn => 'group2',
         member => [
            'CN=item2,OU=whatever',
            'CN=group3,OU=whatever',
            'CN=item3,OU=whatever',
         ],
      },
      {
         objectClass => [ qw< top group > ],
         distinguishedName => 'CN=group3,OU=whatever',
         cn => 'group3',
         member => [
            'CN=item1,OU=whatever',
            'CN=group2,OU=whatever',
            'CN=group4,OU=whatever',
         ],
      },
      {
         objectClass => [ qw< top group > ],
         distinguishedName => 'CN=group4,OU=whatever',
         cn => 'group4',
         member => [
            'CN=group5,OU=whatever',
            'CN=item4,OU=whatever',
            'CN=item6,OU=whatever',
         ],
      },
      {
         objectClass => [ qw< top group > ],
         distinguishedName => 'CN=group5,OU=whatever',
         cn => 'group5',
         member => [
            'CN=item5,OU=whatever',
            'CN=item6,OU=whatever',
         ],
      },
      {
         objectClass => [ qw< top person > ],
         distinguishedName => 'CN=item1,OU=whatever',
         cn => 'item1',
      },
      {
         objectClass => [ qw< top person > ],
         distinguishedName => 'CN=item2,OU=whatever',
         cn => 'item2',
      },
      {
         objectClass => [ qw< top person > ],
         distinguishedName => 'CN=item3,OU=whatever',
         cn => 'item3',
      },
      {
         objectClass => [ qw< top person > ],
         distinguishedName => 'CN=item4,OU=whatever',
         cn => 'item4',
      },
      {
         objectClass => [ qw< top person > ],
         distinguishedName => 'CN=item5,OU=whatever',
         cn => 'item5',
      },
      {
         objectClass => [ qw< top person > ],
         distinguishedName => 'CN=item6,OU=whatever',
         cn => 'item6',
      },
   ];
   state $by_cn = { map { $_->{cn} => $_ } $data->@* } ;
   state $by_dn = { map { $_->{distinguishedName} => $_ } $data->@* };

   return map { m{\A cn= }imxs ? $by_dn->{$_} : $by_cn->{$_} } @requests;
}
```

I hope you find it useful... *future me* 😉

To everybody else, I hope you enjoy it too, and stay safe!

[Perl]: https://www.perl.org/
