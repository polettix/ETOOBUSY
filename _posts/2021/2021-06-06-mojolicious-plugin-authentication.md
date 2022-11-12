---
title: 'Mojolicious::Plugin::Authentication'
type: post
tags: [ perl, mojolicious, security ]
comment: true
date: 2021-06-06 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Notes/tutorial for using [Mojolicious::Plugin::Authentication][].

After much talking about how to save passwords in a file/database
without risking too much the credentials of the users (e.g. see
[Crypt::Argon2][]), it's finally time to take a look at *what to do*
with those account details. Namely, authenticate users.

The [Mojolicious][] web framework has
[Mojolicious::Plugin::Authentication][] to help with this, although it
seems that the documentation makes some assumptions about the overall
model that subsumes its usage.

Which is a complicated way to say that I didn't immediately understand
how to use it, nor I found a tutorial.

I'll try to put down what I understood.

# The Model

The model provided is a quite abstract one, where there are the
following concept:

- an account is associated to a unique identifier, which can be either a
  string or a number;
- two parameters are needed for authentication: a *username* and a
  *password*;
- a successful authentication eventually allows to get the unique
  identifer for the account;
- the account can have a lot of additional data associated, which can be
  retrieved by means of the identifier.

```
(username, password) --[validation]--> (uid)
                                         |
      (account data) <--[loading]--------+
```

I'm not entirely sure why there is no *direct* jump from a
*username*/*password* pair to the *account data*, but I can guess a few
reasons:

- validation is usually performed *rarely*, i.e. one single
  authentication event will clear access for some time. Account data, on
  the other hand, will be needed multiple times. With a `uid` it will be
  easier to manage a *session* on the server side;
- The validation process might be performed according to some other
  model, not based on a *username*/*password* pair. To this end,
  splitting the loading from the validation allows reusing loading.

Going on with the model, the plugin keeps track of the specific status
of authentication for different users based on *session data*. To this
regard:

- the `authenticate()` method takes care to perform the validation, and
  set the session depending on whether this is fine or fails;
- the `is_user_authenticated()` method tells us about the authentication
  status for the current user (depending on the session data);
- the `current_user()` method gives us the account data, if the user is
  authenticated;
- the `logout()` method does... what you think.

There are two additional methods (`reload_user()` and
`signature_exists()`) that do... additional stuff, it's fair to say that
the docs will be fine if you need them.

Most methods also have a *promise-oriented* interface but we will not
look at it here.

# What we have to provide

Based on the model, it's clear that the *validation* and *loading*
actions is where all customization happens.

Do we store accounts in a plain file? A database? A crystal ball? No
problem! As long as we provide access to these storage facilities
through a pair of *callback functions* we will be fine.

As an example, suppose that we keep our data in a hash, where each
*username* doubles down as an identifier and the data holds the full
account details in a hash reference:

```perl
{
   my %db = (
      foo => { password => 'FOO', name => 'What Ever' },
      # ...
   );
   sub load_account ($username) { return $db{$username} // undef }
   sub validate ($username, $password) {
      my $account = load_account($username) // return;
      return $password eq $account->{password} ? $username : undef;
   }
}
```

**Of course** this is an example, we already discussed how to avoid
storing passwords in clear, right?!?

Our simple authentication code is *almost* compliant to what
[Mojolicious::Plugin::Authentication][] needs, in that it complies to
the model above, but the functions are not 100% in line with what the
module expects. No problem, because we can *wrap* the functions above to
do the interface adaptation when loading the plugin:

```perl
use Mojolicious::Lite -signatures;
use Mojolicious::Plugin::Authentication;
# ...
app->plugin(
    Authentication => {
        load_user     => sub ($app, $uid) { load_account($uid) },
        validate_user => sub ($c, $u, $p, $e) { validate($u, $p) },
    }
);
```

Well... this is really it for the setup!

It's possible to grow a lot from here, e.g.:

- save helpers for validation and/or loading code, and use that instead
  of our simple facility;
- tweak automatic loading of users with `autoload_user`. This can e.g.
  come handy if we're using a database or loadind data dynamically from
  a file, because in one sweep we can both validate the user and grab
  the relevant data, avoiding some effort later.

# How to use the authentication (basic)

After setting up the plugin with the *adapters* for our own account
management solution, it's time to actually put the plugin to use.

A model that is commonly adopted is the following:

- some routes require authentication, other routes are widely accessible
  (e.g. the route for logging in);
- widely accessible routes don't care about the authentication status
  (although they might care about the session data);
- there is some way to do the authentication, which might involve e.g.
  [HTTP Basic Authentication][] or explicit handling via some `/login`
  route.

Along the way, it's also useful to have the *user*'s data at hand, e.g.
to customize the appearance, show the relevant information, etc.

To this end, the *main facilities* that are available to us as
programmers are:

- `authenticate()`: lets us use a *username*/*password* pair to set the
  internal status of the application for it. This calls *our* validation
  routine behind the scenes, and acts according to the validation
  outcome;
- `is_user_authenticated()`: this lets us check if the request comes
  from an authenticated user, and act accordingly;
- `current_user()`: this lets us retrieve the data about the user that
  sent the request, if authenticated.

So, in general, we will use `authenticate()` in a *login* route like
this:

```perl
post '/login' => sub ($c) {
   my $u = $c->param('username');
   my $p = $c->param('password');
   $c->redirect_to($c->authenticate($u, $p) ? 'private' : 'login');
};
```

Then we use `is_user_authenticated()` in places where we want to
restrict access, e.g.:

```perl
get '/private' => sub ($c) {
   return $c->redirect_to('/login') unless $c->is_user_authenticated;
   return $c->render(template => 'private');
};
```

This makes sure that users have to authenticate before accessing the
restricted areas.

# Surface scratched!

This was about as much as scratching the surface, but it hopefully gets
one started. I'm talking to you, future me!

For everybody else... stay safe!


[Mojolicious::Plugin::Authentication]: https://metacpan.org/pod/Mojolicious::Plugin::Authentication
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Crypt::Argon2]: {{ '/2021/06/05/crypt-argon2/' | prepend: site.baseurl }}
