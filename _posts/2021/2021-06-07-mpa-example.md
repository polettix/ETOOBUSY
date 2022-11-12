---
title: 'Mojolicious::Plugin::Authentication example'
type: post
tags: [ perl, mojolicious, security ]
comment: true
date: 2021-06-07 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A full example of using [Mojolicious::Plugin::Authentication][].

In previous post [Mojolicious::Plugin::Authentication][prepost] we took
a look at... [Mojolicious::Plugin::Authentication][], a useful plugin
for [Mojolicious][] that can help us with managing authentication.

Here we take a look at a *minimal* and *simplistic* example for using
it.

```perl
#!/usr/bin/env perl
use Mojolicious::Lite -signatures;

{
   my %db = (
      foo => {pass => 'FOO', name => 'Foo De Pois'},
      bar => {pass => 'BAZ', name => 'Bar Auangle'},
   );
   sub load_account ($u) { return $db{$u} // undef }
   sub validate ($u, $p) {
      warn "user<$u> pass<$p>\n";
      my $account = load_account($u) or return;
      return $account->{pass} eq $p;
   }
}

app->plugin(
   Authentication => {
      load_user     => sub ($app, $uid) { load_account($uid) },
      validate_user => sub ($c, $u, $p, $e) { validate($u, $p) ? $u : () },
   }
);

app->hook(
   before_render => sub ($c, $args) {
      my $user = $c->is_user_authenticated ? $c->current_user : undef;
      $c->stash(user => $user);
      return $c;
   }
);

get '/' => sub ($c) { $c->render(template => 'index') };

get '/login' => sub ($c) { $c->render(template => 'login') };

post '/login' => sub ($c) {
    my $username = $c->param('username');
    my $password = $c->param('password');
    if ($c->authenticate($username, $password)) {
       warn $c->is_user_authenticated ? 'YES' : 'NOT YET';
        $c->redirect_to('/private');
    }
    else {
        $c->redirect_to('login');
    }
    return;
};

get '/private' => sub ($c) {
    return $c->redirect_to('/login') unless $c->is_user_authenticated;
    return $c->render(template => 'private');
};

post '/logout' => sub ($c) {
    $c->logout if $c->is_user_authenticated;
    return $c->redirect_to('/');
};

app->start;

__DATA__
@@ layouts/layout.html.ep
<!DOCTYPE html>
<html lang="en">
  <head><title>Whatevah</title></head>
  <body>
    <%= content %>
    <hr>
%= t a => href => '/' => 'Home';
-
%= t a => href => '/login' => 'Login';
-
%= t a => href => '/private' => 'Private';
% if (defined $user) {
<form action="/logout" method="post"
   style="display: inline"
>
-
<button type="submit"
   style="background: none!important;
          border: none;
          padding: 0!important;
          text-decoration: underline;
          cursor: pointer;
          color: #069;">Logout <%= $user->{name} %></button>
</form>
% }
  </body>
</html>

@@ index.html.ep
% layout 'layout';
%= t h1 => 'Index - Free Access'

@@ private.html.ep
% layout 'layout';
%= t h1 => 'Private Stuff - Retricted Access'
Welcome <%= $user->{name} %>

@@ login.html.ep
% layout 'layout';
%= t h1 => 'login'
%= form_for '/login' => (method => 'post') => begin
username: <%= text_field 'username' %>
password: <%= password_field 'password' %>
%= submit_button 'log in' 
%= end
```

The example should not require much explanation, as it leverages on the
concepts and functions described in the [previous post][prepost].

One thing that can be elaborated a bit is this part here:

```perl
app->hook(
   before_render => sub ($c, $args) {
      my $user = $c->is_user_authenticated ? $c->current_user : undef;
      $c->stash(user => $user);
      return $c;
   }
);
```

In practice, we are always setting a `user` key in the stash, putting
the information about the current user (via `current_user()`) if
available, or nothing (`undef`) otherwise. In this way, our templates
will have the data structure for the account at their disposal, e.g. to
show the user's name etc.

[prepost]: {{ '/2021/06/06/mojolicious-plugin-authentication/' | prepend: site.baseurl }}
[Mojolicious::Plugin::Authentication]: https://metacpan.org/pod/Mojolicious::Plugin::Authentication
[Mojolicious]: https://metacpan.org/pod/Mojolicious
