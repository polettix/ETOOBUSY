---
title: GeoIP database from MaxMind
type: post
tags: [ geoip, geo-localization, fail2ban ]
comment: true
date: 2022-02-28 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> [MaxMind][] provides a [free version of their Geo-localization
> database][freedb], useable from [Perl][].

Which is pretty cool.

I've hit slightly less than 1.2 k banned IPs in a [Fail2ban][] instance
and I was curious about it, so I needed to translate a list of IP
addresses into country names.

Luckily, [IP::Geolocation::MMDB][] and a [free DB][freedb] by
[MaxMind][] made the translation possible *and* fun.

This is what came out:

```
China 254
United States 218
Hong Kong 93
Singapore 72
India 70
Germany 53
Netherlands 36
Indonesia 31
Brazil 30
United Kingdom 28
South Korea 28
Russia 27
Vietnam 24
Canada 14
Japan 13
France 12
Thailand 11
Italy 11
...
```

I was expecting China first, less so the other ones. **How beautiful is
that we can challenge our own self-delusions and biases with data?**

Stay safe!

[Perl]: https://www.perl.org/
[MaxMind]: https://www.maxmind.com/en/home
[freedb]: https://dev.maxmind.com/geoip/geolite2-free-geolocation-data
[Fail2ban]: https://www.fail2ban.org/wiki/index.php/Main_Page
[IP::Geolocation::MMDB]: https://metacpan.org/pod/IP::Geolocation::MMDB
