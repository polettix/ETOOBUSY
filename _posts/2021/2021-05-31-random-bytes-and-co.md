---
title: Random bytes and co.
type: post
tags: [ perl, security ]
comment: true
date: 2021-05-31 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Generating some randomness for seeds.

In previous post [Bcrypt password hashing][] we took a look at the 
[Crypt::Eksblowfish::Bcrypt][] module and eventually came out with the
following function:

```perl
sub create_account ($username, $password, $cost, $salt = undef) {
   $salt //= pack 'C*', map {int rand 256} 1 .. 16;
   my $settings = sprintf '$2a$%02d$%s', $cost, en_base64($salt);
   save_user($username, bcrypt($password, $settings));
}
```

The `$salt` parameter is aimed at avoiding a lot of pre-computation of
stuff etc. to strengthen the security of the whole system, and we are
filling in a *default* one leveraging [Perl][]'s internal [rand][]
function.

As [the documentation makes clear][rand]:

> [rand][] is not cryptographically secure. You should not rely on it in
> security-sensitive situations. As of this writing, a number of
> third-party CPAN modules offer random number generators intended by
> their authors to be cryptographically secure, including:
> [Data::Entropy][], [Crypt::Random][], [Math::Random::Secure][], and
> [Math::TrulyRandom][].

I think it's probably fair to add that there are other modules too, like
[Crypt::Random::Seed][] and [Bytes::Random::Secure::Tiny][].

In **my** typical situation, though, I'm in a [Linux][] environment not
from *ages* ago, so we might rely on `/dev/urandom` directly:

```perl
sub salt_please {
   open my $fh, '< :raw :bytes', '/dev/urandom'
      or die "open('/dev/urandom'): $!\n";
   my $retval = '';
   while ((my $len = length $retval) < 16) {
      read($fh, $retval, 16 - $len, $len) // die "read(): $!\n"
   }
   close $fh;
   return $retval;
}
```

This is probably an overkill implementation of *read 16 bytes from
`/dev/urandom`* - in particular, I don't expect the `while` loop to
really kick in more than once.

So now you can put some *salt* on your *seeds*, uh?

[Bytes::Random::Secure::Tiny]: https://metacpan.org/pod/Bytes::Random::Secure::Tiny
[Data::Entropy]: https://metacpan.org/pod/Data::Entropy
[Crypt::Random]: https://metacpan.org/pod/Crypt::Random
[Crypt::Random::Seed]: https://metacpan.org/pod/Crypt::Random::Seed
[Math::Random::Secure]: https://metacpan.org/pod/Math::Random::Secure
[Math::TrulyRandom]: https://metacpan.org/pod/Math::TrulyRandom
[Bcrypt password hashing]: {{ '/2021/05/30/bcrypt/' | prepend: site.baseurl }}
[Crypt::Eksblowfish::Bcrypt]: https://metacpan.org/pod/Crypt::Eksblowfish::Bcrypt
[Perl]: https://www.perl.org/
[rand]: https://perldoc.perl.org/functions/rand
[Linux]: https://www.kernel.org/
