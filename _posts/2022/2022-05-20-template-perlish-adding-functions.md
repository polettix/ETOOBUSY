---
title: 'Adding functions in Template::Perlish'
type: post
tags: [ perl, template ]
comment: true
date: 2022-05-20 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Notes on "adding" functions for a template.

As any average [Perl][] hacker, I passed through *that* phase where I
had the urge to produce my own templating system.

There was a reason - there's always a reason, right?!? - in that I
wanted a single-file module that I could easily embed with my programs,
and nothing at that time ticked all checkboxes.

This marked the start of [Template::Perlish][]. It's a lazy approach to
adding business logic, because it's a sort of poor man's PHP where
templates are a mix of data and [Perl][] code.

It's *obviously* not for the web, but it's quite handy for situations
where there's full control over both the templates and the data fed into
them. I have used it since it was born and I never regret using it when
the need arises. By the way, it's the module behind [teepee][].

Templates have the full power of [Perl][] at their disposal. As an
example, I recently wrote about [ActiveDirectory password encoding in
Perl and shell][], which might be used like this in a template:

```ldif
dn: CN=TestUser,DC=testdomain,DC=com
changetype: modify
replace: unicodePwd
unicodePwd:: [%=
    use Encode 'encode';
    use MIME::Base64 'encode_base64';
    my $password = 'newPassword';
    encode_base64(encode('UTF-16LE', qq{"$password"}), '');
%]
```

This admittedly sucks, but it can be written in a more readable way:

```ldif
[%
    sub encode_password {
        require Encode;
        require MIME::Base64;
        my $password = shift;
        return MIME::Base64::encode_base64(
            Encode::encode('UTF-16LE', qq{"$password"}),
            '', # no newlines, please!
        );
    }
%]
dn: CN=TestUser,DC=testdomain,DC=com
changetype: modify
replace: unicodePwd
unicodePwd:: [%= encode_password('newPassword') %]
```

The natural evolution of this is that the sub is put *elsewhere*, like a
module:

```ldif
[%
    use MyUtils qw< encode_password >;
%]
dn: CN=TestUser,DC=testdomain,DC=com
changetype: modify
replace: unicodePwd
unicodePwd:: [%= encode_password('newPassword') %]
```

Another approach might be to *inject* the `encode_password` function
directly from the [Perl][] program that uses [Template::Perlish][] for
the rendering. This might e.g. be done like this:

```perl
use v5.24;
use warnings;
use Template::Perlish 'render';

my $template = <<'END';
dn: CN=TestUser,DC=testdomain,DC=com
changetype: modify
replace: unicodePwd
unicodePwd:: [%= encode_password(V 'password') %]
END

sub render_with_benefits {
    package Template::Perlish;
    no warnings 'once';
    local *encode_password = sub {
        require Encode;
        require MIME::Base64;
        my $password = shift;
        return MIME::Base64::encode_base64(
            Encode::encode('UTF-16LE', qq{"$password"}),
            '', # no newlines, please!
        );
    };
    return render(@_);
}

say render_with_benefits($template, {password => 'newPassword'});
```

Some takeaways:

- at the moment, all templates are rendered within `Template::Perlish`
  as the current package. This is why we put the `package ...` line
  inside the sub;
- we use `local` to avoid polluting the `Template::Perlish` namespace
  for other templates that do not need to use that new function.
- the `no warnings...` is to silence the check by [Perl][] while setting
  `encode_password`. It might be done differently.


Stay safe and rendered!

[Perl]: https://www.perl.org/
[Template::Perlish]: https://metacpan.org/pod/Template::Perlish
[teepee]: {{ '/2021/03/16/teepee/' | prepend: site.baseurl }}
[ActiveDirectory password encoding in Perl and shell]: {{ '/2022/05/16/ad-password-perl-and-shell/' | prepend: site.baseurl }}
