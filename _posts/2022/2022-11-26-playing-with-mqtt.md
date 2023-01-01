---
title: Playing with MQTT
type: post
tags: [ perl, mqtt ]
comment: true
date: 2022-11-26 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Some playing with [MQTT][], [Net::MQTT][], and [Net::MQTT::Simple][].

I recently discovered [Software Tools for Hobby-Scale Projects][] and
there's the interesting presence of [Free MQTT servers][public brokers].

Now I don't even know what's the exact use case for [MQTT][], but I
think it's fun to see that [Perl][] gets me covered anyway with
[Net::MQTT][].

So, [after installing it][pmi], we can start using the provided example
programs and *they work*!

In one terminal we can set to *listen* for incoming messages, i.e. act
as a *subscriber* on one or more topic. We'll subscribe to two topics,
`this` and `and-that`:

```
local/bin/net-mqtt-sub -host test.mosquitto.org this and-that
```

Then, in another terminal, we can connect as a *publisher*, e.g. on
topic `this`:

```
local/bin/net-mqtt-pub -host test.mosquitto.org this
```

Now whatever we write in the latter one will appear in the former. We
can also use a third terminal (or replace the program in the second one)
to connect, as a publisher, to the other topic:

```
local/bin/net-mqtt-pub -host test.mosquitto.org and-that
```

The subscriber is able to get the topic, as shown by the sample output:

```
this hello from this
this how are you doing?
and-that hello from the other one
and-that I hope everything is fine!
```

The code is not super-user-friendly, the documentation is a bit blunt
and it seems that we're supposed to do the `Net` part all by ourselves.
So, I guess, it could have been named `Data::MQTT` or something like
this.

For something more ready-to-use, [Net::MQTT::Simple][] seems more
friendly. Stealing from the [SYNOPSIS][], implementing a publisher is a
no-brainer, easily done from the command line:

```
perl -MNet::MQTT::Simple=test.mosquitto.org \
     -nle 'retain "topic/here" => $_'
```

or programmatically:

```perl
use Net::MQTT::Simple "test.mosquitto.org";
 
publish "topic/here" => "Message here";
retain  "topic/here" => "Retained message here";
```

The subscriber is marginally more complicated, but it provides the
flexibility of connecting to multiple topics at the same time much like
we have in [Net::MQTT][]:

```perl
use Net::MQTT::Simple;
 
my $mqtt = Net::MQTT::Simple->new("mosquitto.example.org");
$mqtt->run(
    "sensors/+/temperature" => sub {
        my ($topic, $message) = @_;
        die "The building's on fire" if $message > 150;
    },
    "#" => sub {
        my ($topic, $message) = @_;
        print "[$topic] $message\n";
    },
);
```

I guess this is it!

[Perl]: https://www.perl.org/
[MQTT]: https://mqtt.org/
[Net::MQTT]: https://metacpan.org/pod/Net::MQTT
[public brokers]: https://github.com/mqtt/mqtt.org/wiki/public_brokers
[Software Tools for Hobby-Scale Projects]: {{ '/2022/10/31/hobby-scale-projects/' | prepend: site.baseurl }}
[pmi]: {{ '/2020/01/04/installing-perl-modules/' | prepend: site.baseurl }}
[Net::MQTT::Simple]: https://metacpan.org/pod/Net::MQTT::Simple
[SYNOPSIS]: https://metacpan.org/pod/Net::MQTT::Simple#SYNOPSIS
