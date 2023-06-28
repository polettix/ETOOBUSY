---
title: 'Mojo::UserAgent'
type: page
tags: [ mojolicious, perl, user agent ]
date: 2023-06-23 07:00:00 +0100
doc: true
mathjax: false
toc: true
published: true
---

<div class="page-nav" markdown="1">

{:toc}
* this is the toc

</div>
<div class="post-content" id="content" markdown="1">

Notes about [Mojo::UserAgent][] that can come handy all in one place, in a
synthetic form. More and better stuff in [Commented examples in the
Cookbook][].

# SYNOPSIS

This is *adapted* from the first example in the [SYNOPSIS][] (as of this
post's date, anyway):

{% include code_header.html %}
```perl
use Mojo::UserAgent;
my $ua = Mojo::UserAgent->new(connect_timeout => 2, max_redirects => 5);
$ua->proxy->detect;
```

{% include code_header.html %}
```perl
my $res = $ua->get($url, \%headers, form => \%query_data)->res;
if ($res->is_success)  {
    say $res->body
}
else { # error handling, log/warn/die/croak/ouch/...
    die 'connection error' unless $res->code;
    die 'got error ' . $res->message if $res->is_error;
    die 'got status code ' . $res->code;
}
```

# Setup

Here is where we get a user agent object and, if needed, we set up automatic
proxy detection too.

## Get a UserAgent object

Use `new` to get a [Mojo::UserAgent][] object, pass the [ATTRIBUTES][] you
want to set:

{% include code_header.html %}
```perl
my $ua  = Mojo::UserAgent->new(
    connect_timeout => 2,
    max_redirects   => 5,
);
```

All [ATTRIBUTES][] can also be set in chaining mode if this style is
preferred:

{% include code_header.html %}
```perl
my $ua  = Mojo::UserAgent->new
    ->connect_timeout(2),
    ->max_redirects(5);
```

## Proxy

**No "common" environment variables by default**. They can be [detect][]ed
though:

- *implicitly*: set `MOJO_PROXY=1` in the calling environment
- *explicitly*:

{% include code_header.html %}
```perl
$ua->proxy->detect;
```

The `proxy` method gives back an object of class [Mojo::UserAgent::Proxy][]
for fancier configurations.


# Response

Using HTTP is about making requests and getting responses back. Let's assume
you're more focused on the latter here.

## Use `res`

The outcome of a [get][] (or [post][], or...) is a
[Mojo::Transaction::HTTP][] (/[Mojo::Transaction][]) object, but this is
generally not what is needed. `res` is.

{% include code_header.html %}
```perl
my $res = $ua->get($url)->res;
if ($res->is_success)  {
    say $res->body
}
else { # error handling, log/warn/die/croak/ouch/...
    die 'connection error' unless $res->code;
    die 'got error ' . $res->message if $res->is_error;
    die 'got status code ' . $res->code;
}
```

> The other method `result` throws an exception if there is a connection
> timeout. To this extent, it's somehow a half-baked solution because error
> conditions must be checked in two different ways.


## `is_success`, `is_error`, or...?

Errors can be checked upon a `res`ponse, usually `is_success` should suffice:

{% include code_header.html %}
```perl
my $res = $ua->get($url)->res;
die 'whatever' unless $res->is_success;
say $res->body;
```

Connection errors yield a *false* value for `$res->code` in boolean context.
Otherwise, there are a few methods for checking the
[Mojo::Message::Response][], listed below. If `max_redirects` is set to a
non-zero value, the response contains the outcome after following the
allowed redirections.

Checks suitable for **boolean context**:

- `code`: *false* upon connection errors
- `is_success`: `2xx` (OK)
- `is_redirect`: `3xx` (redirection)
- `is_error`: `4xx` or `5xx` (client or server error)
- `is_client_error`: `4xx` (client-side error)
- `is_server_error`: `5XX` (server-side error)
- `is_info`: `1xx` (informational)
- `is_empty`: `1xx`, `204` (OK, no content), or `304` (not modified)


{% include code_header.html %}
```perl
my $res = $ua->get($url)->res;
die 'connection error' unless $res->code;
die 'we should see elsewhere maybe?' if $res->is_redirect;
# die 'something did not work here or there' if $res->error;
die 'we messed up our request' if $res->is_client_error;
die 'remote server is feeling bad' if $res->is_server_error;
say $res->body;
```

## Get the data: `body`/`dom`/`json` (and others)

Data can be extracted from a successful response, which is also a
[Mojo::Message][] object:

```perl
my $res = $ua->get($url)->res;
die 'whatever' unless $res->is_success;
```

Most of the times `body`/`dom`/`json` provide what is needed:

```
my $stringish  = $res->body;
my $dom        = $res->dom;  # for a HTML/XML body
my $structured = $res->json; # for a JSON-encoded body
```

The `$dom` returned by `$res->dom` is a [Mojo::DOM][] object.

Method `ŧext` can be useful to automatically apply a charset.

`content` is *rarely* what is needed --it is a lower level interface,
suitable for fiddling.

Last, `message` refers to the small text that is usually provided along with
a HTTP status code (like the `OK` in `200 OK`. Rarely what is acually
needed.

## Look at `headers`

Headers in a response can be of help sometimes:

{% include code_header.html %}
```perl
my $res = $ua->get($url)->res;
my $headers = $res->headers;
```

The `$headers` variable is a [Mojo::Headers][] object, which gives easy
access to common headers, using methods that are derived from the official
header names, all lowercase and with all hyphens turned into underscores:

{% include code_header.html %}
```perl
my $type        = $headers->content_type;
my $disposition = $headers->content_disposition;
my $length      = $headers->content_length;
my $date        = $headers->date;
my $host        = $headers->host;
my $location    = $headers->location;
my $referer     = $headers->referer; # also $headers->referrer
# other available
```

For all of them see [Mojo::Headers][].

All headers, including less-common ones, are also available through the
generic `header` method, providing the name of the header (case does not
matter):

{% include code_header.html %}
```perl
my $type_alt1 = $headers->header('content-type');  # all lowercase
my $type_alt2 = $headers->header('Content-Type');  # Camel Case
my $type_alt2 = $headers->header('cOnTeNt-tYpE');  # kiddie?
my $generic   = $headers->header('X-my-header');
```

# Request

If you need to craft the request, read on.

## Send form data

Sending a HTTP form can be done by adding two parameters in the request
([get][], [post][], ...), the first being `form` and the second a hash
reference with key/value pairs.

GET requests have form data encoded in the URL:

{% include code_header.html %}
```perl
my %form_data = (foo => bar, multi => [ qw< first second third > ]);
my $res = $ua->get($url, form => \%form_data);
```

POST (and other HTTP verbs that allow for a request body) have form data set
in the body and content-type set to `application/x-www-form-urlencoded`:

{% include code_header.html %}
```perl
my %form_data = (foo => bar, multi => [ qw< first second third > ]);
my $res = $ua->post($url, form => \%form_data);
```

Multiple values for the same key can be passed using an array reference,
like in the example above.

## Send JSON-encoded data

Encoding a data structure as a JSON string to send as the request body (e.g.
while consuming a remote API) can be done easily:

{% include code_header.html %}
```perl
my $res = $ua->post($url, json => $request_data_structure);
```

This also works for other HTTP verbs that allow for a request body, like
`PUT`.

## Upload a file

A HTTP file upload is usually arranged as a POST form with `Content-Type`
set to `multipart/form-data`. Just treat it as a regular `form` and pass the
data as a `file`, like the example below:

{% include code_header.html %}
```perl
$ua->post('https://example.com/send-file', form => {
    foo => {file => '/on/to/something.png'},
    bar => 'howdy!',
    baz => 'go!',
});
```

It roughly corresponds to the following HTML form:

```html
<form method="POST" action="https://example.com/send-file">
    <input  type="file"   name="foo">
    <input  type="hidden" name="bar" value="howdy!">
    <button type="submit" name="bar" value="go!">
</form>
```

In both the [Mojo::UserAgent][] and the HTML form, the presence of the
`file` form field triggers usage of the right `Content-Type`.

## Fiddle with `headers`

All request methods ([get][], [post][], ...) take a URL (or equivalent) as
the first required parameter, then accept other optional parameters.

One optional parameter is a hash reference that is used to set specific HTTP
headers in the request:

{% include code_header.html %}
```perl
my $res = $ua->get($url, { Authorization => 'Basic ZnU6YmFy' })->res;
```

Pass an array reference to set a list of values for the same header key:

{% include code_header.html %}
```perl
my $res = $ua->get($url, { 'X-foo' => [qw< foo bar >] })->res;
```

If you end up with a *transaction object* [Mojo::Transaction::HTTP][] (e.g.
via [build\_tx][btx]) that still has to be sent, it's possible to get the
headers handling object and manipulate them through it:

{% include code_header.html %}
```perl
my $tx = $ua->build_tx(GET => $url);

my $headers = $tx->headers;
$headers->remove('Accept-Encoding');
$headers->header('X-foo' => qw< foo bar >);

$ua->start($tx);
```

## Basic Authentication

It's possible to just put the credentials in the URL and it will be put in
the right place:

{% include code_header.html %}
```perl
my $res = $ua->get('https://$user:$pass@example.com/');
```

Code can be cleaner using a [Mojo::URL][] object and method `userinfo`:

{% include code_header.html %}
```perl
use Mojo::URL;
my $url = Mojo::URL->new('https://example.com/')->userinfo("$user:$pass");
my $res = $ua->get($url)->res;
```

The bottom line is that Basic Authentication data end up as a
`Authorization` header in the HTTP request, so it's possible to go the long
way and set it directly:

{% include code_header.html %}
```perl
use Mojo::Util 'b64_encode';
my $encoded = b64_encode("$user:$pass", '')
my $res = $ua->get($url, {Authorization => "Basic $encoded"});
```

# Useful links

The following pages can help a lot:

- [SYNOPSIS][]
- [Commented examples in the Cookbook][]
- [Mojo::Message][] and [Mojo::Message::Response][]

[Mojo::UserAgent]: https://metacpan.org/pod/Mojo::UserAgent
[Mojo::UserAgent::Proxy]: https://metacpan.org/pod/Mojo::UserAgent::Proxy
[Commented examples in the Cookbook]: https://metacpan.org/pod/distribution/Mojolicious/lib/Mojolicious/Guides/Cookbook.pod#USER-AGENT
[SYNOPSIS]: https://metacpan.org/pod/Mojo::UserAgent#SYNOPSIS
[Mojo::Message]: https://metacpan.org/pod/Mojo::Message
[Mojo::Message::Response]: https://metacpan.org/pod/Mojo::Message::Response
[Mojo::Transaction::HTTP]: https://metacpan.org/pod/Mojo::Transaction::HTTP
[Mojo::Transaction]: https://metacpan.org/pod/Mojo::Transaction
[ATTRIBUTES]: https://metacpan.org/pod/Mojo::UserAgent#ATTRIBUTES
[get]: https://metacpan.org/pod/Mojo::UserAgent#get
[post]: https://metacpan.org/pod/Mojo::UserAgent#post
[detect]: https://metacpan.org/pod/Mojo::UserAgent::Proxy#detect
[Mojo::DOM]: https://metacpan.org/pod/Mojo::DOM
[Mojo::Headers]: https://metacpan.org/pod/Mojo::Headers
[btx]: https://metacpan.org/pod/Mojo::UserAgent#build_tx
[Mojo::URL]: https://metacpan.org/pod/Mojo::URL
[Perl]: https://www.perl.org/

</div>
