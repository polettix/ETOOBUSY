---
title: 'Crypt::Argon2'
type: post
tags: [ perl, security ]
comment: true
date: 2021-06-05 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Using [Crypt::Argon2][] is probably a better alternative to [Bcrypt
> password hashing][].

After [APR1 password verification][] came [Bcrypt password hashing][].
But, of course, I had to look if there's anything newer, and sure there
is.

It's like opening the proverbial *can of worms*, except that this time
the can contains a lot of good food.

It all starts from the [Password Hashing Competition][] and its winner,
the [Argon2][] password:

> We recommend that you use Argon2 rather than legacy algorithms.

Next step is to make a bet... *is there a module for this in [CPAN][]*?

Sure there is: [Crypt::Argon2][]. There are a few alternative functions
to choose from, but sticking with the `id` variants provides us this:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

use FindBin '$Bin';
use lib "$Bin/local/lib/perl5";

use Crypt::Argon2 qw< argon2id_pass argon2id_verify >;
use Crypt::URandom 'urandom';
use Test::More;

{
   my %db;
   sub save_user ($u, $p) { $db{$u} = $p }
   sub get_user_hashed_password ($u) { return $db{$u} // undef }
}

sub salt_please { return urandom(16) }

sub create_account ($username, $password, $cost, $salt = undef) {
   $salt //= salt_please();
   my $encoded = argon2id_pass($password, $salt, $cost, '32M', 1, 16);
   save_user($username, $encoded);
}

sub authenticate ($username, $password) {
   my $expected = get_user_hashed_password($username) // return;
   return argon2id_verify($expected, $password);
}

create_account(foo => 'barbaz', $ENV{BCRYPT_COST} // 9);

my $hp = get_user_hashed_password('foo');
like $hp, qr{\A\$argon2id\$}mxs, 'hashed password saved as expected';

ok ! authenticate(foo => $_), 'attempt wrong password'
   for qw< bar baz bar-baz >;
ok   authenticate(foo => 'barbaz'), 'authenticate with right pass';

done_testing;
```

If you're wondering... *yes, this is mostly copied from [Bcrypt password
hashing][]*, and for good reasons: it reuses that scaffolding and fills
in a different implementation for the same interface, in good spirit of
encapsulation.

This is *so* interesting!

[Bcrypt password hashing]: {{ '/2021/05/30/bcrypt/' | prepend: site.baseurl }}
[APR1 password verification]: {{ '/2021/05/29/apr1-verification/' | prepend: site.baseurl }}
[Password Hashing Competition]: https://www.password-hashing.net/
[Argon2]: https://www.password-hashing.net/#argon2
[CPAN]: https://metacpan.org/
[Crypt::Argon2]: https://metacpan.org/pod/Crypt::Argon2
