---
title: 'Validate::CodiceFiscale update'
type: post
tags: [ perl ]
comment: true
date: 2023-08-07 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [Validate::CodiceFiscale][] now supports place validation and
> decoding.

After coding the initial release of [Validate::CodiceFiscale][], it was
clear that there was a big elephant in the room:

> Places are required to be entered as official codes, but there is no
> validation that the specific code was active at the date of birth in
> the Codice Fiscale.

I can't say that this went away completely, but I think we're more or
less in the right *place*, thanks to data I fetched from
official/affordable sources (as reflected in the [data
license][data-license] section).

There is [some code in the repository][support] to allow for easy
maintenance as things evolve, e.g. with new releases of the data.

In addition to the validation part, which will hopefully work in most
cases, the module also gets a new addition `decode_cf`, which returns
the decoded data after validation, in case additional checks are needed.
One such case would be comparing the place of birth with some possible
variations of a specific name, like e.g. the name in another language
instead of Italian.

One final remark: the *one and only* validator for this code is the
[Verifica codice fiscale di persona fisica o di soggetto diverso da persona fisica][official] - everything else is just an approximation that can be
useful to brush off some negative cases instead of asking the agency.

[Perl]: https://www.perl.org/
[Validate::CodiceFiscale]: https://metacpan.org/pod/Validate::CodiceFiscale
[trial]: https://metacpan.org/release/POLETTIX/Validate-CodiceFiscale-0.003001-TRIAL/view/lib/Validate/CodiceFiscale.pod
[data-license]: https://metacpan.org/release/POLETTIX/Validate-CodiceFiscale-0.003001-TRIAL/view/lib/Validate/CodiceFiscale.pod#Data
[support]: https://codeberg.org/polettix/Validate-CodiceFiscale/src/branch/main/support/territorio
[official]: https://telematici.agenziaentrate.gov.it/VerificaCF/IVerificaCf.jsp
