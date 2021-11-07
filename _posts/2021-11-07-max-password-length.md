---
title: 'Max password length... WTF?!?'
type: post
tags: [ internet, rant ]
comment: true
date: 2021-11-07 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I wonder why setting a (little) **maximum** password length.

Passwords (or their grown-up cousins *passphrases*) should be strong,
right?

Up to a few years ago, this was basically translated into recommending a
minimum width (usually around 8 characters) and forcing users to use
uppercase, lowercase and special characters.

In 2017, [NIST][] updated their guidelines based on a few more years of
experience, with [NIST Special Publication 800-63][nistpub]. Among other
suggestions, it's pretty clear that length matters (e.g. [Appendix A][]
in [Digital Identity Guidelines - Authentication and Lifecycle
Management][63b]):

> Password length has been found to be a primary factor in
> characterizing password strength \[[Strength]()\] \[[Composition]()\].
> Passwords that are too short yield to brute force attacks as well as
> to dictionary attacks using words and commonly chosen passwords.

[xkcd][] gets the gist of the updated view about complexity in [936][]:

![xkcd on password strength](https://imgs.xkcd.com/comics/password_strength.png)

I still see places that put a *low* limit to password length and I
wonder... *WHAT THE FUTZ*?!? (By *low* I mean around 16 characters. **16
characters**... [xkcd 936][936]'s password would be out of luck.)

[Appendix A][] has something to say to this regard:

> Users should be encouraged to make their passwords as lengthy as they
> want, within reason. Since the size of a hashed password is
> independent of its length, there is no reason not to permit the use of
> lengthy passwords (or pass phrases) if the user wishes. Extremely long
> passwords (perhaps megabytes in length) could conceivably require
> excessive processing time to hash, so it is reasonable to have some
> limit.

So... please everybody let's not limit users' creativeness in choosing
strong passphrases that will be easy for them to remember!

I hope no more rants in the few days ahead!

[nistpub]: https://pages.nist.gov/800-63-3/sp800-63-3.html
[NIST]: https://www.nist.gov/
[xkcd]: https://xkcd.com/
[936]: https://xkcd.com/936/
[Strength]: https://pages.nist.gov/800-63-3/sp800-63b.html#strength
[Composition]: https://pages.nist.gov/800-63-3/sp800-63b.html#composition
[63b]: https://pages.nist.gov/800-63-3/sp800-63b.html
[Appendix A]: https://pages.nist.gov/800-63-3/sp800-63b.html#appA
