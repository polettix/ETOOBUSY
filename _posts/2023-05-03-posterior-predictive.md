---
title: Posterior Predictive
type: post
tags: [ bayes, statistics ]
comment: true
date: 2023-05-03 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> A note about [this video section][] on Posterior Predictive.

I'm looking at the lectures in [Statistical Rethinking 2023][] by
[Richard McElreath][] and I was hit by [this video section][].

Initially, I could not make heads or tails with it. I mean, the process
was clear *enough* after viewing it some three-four times, but *why* was
too above my head.

So I headed to [the book][] and to [the previous version of the
section][] (from 2022) and ideas started forming in my head... I hope I
got them right and my dear future me will be able to remeber that I'm
writing them here.

1. This is an *example*. The basic question is "how about predicting the
future if we want to draw 9 more values?". There's really nothing
special in the number 9, *but* the interesting thing is that we put the
Posterior distribution (which is about the water proportion $p$) into a
prediction about *something different although related*, i.e. how many
more *water*s we can expect if we want to do 9 more draws. Put in
another way: the $x$ axis of the Posterior distribution is $p$, the $x$
axis of the Posterior Predictive in this example is *number of Ws*.

2. The Posterior Predictive might have been about something else, even
for the same Posterior distribution. E.g. about the number of land
draws. Or about the number of water draws in a run of 20. So, again,
it's an example.

3. The whole point of doing all the draws and accumulations is to remind
the user that *distributions matter*. Summarizing them with very few
numbers can be useful, but very often misleading. So even in the
predictions, let's build a distribution and get a real feel for the
simulated stuff.

4. Doing the calculation of the Posterior Predictive *transfers the
uncertainty in the Posterior on to the Prediction*. Which also means: if
we have a very tight Posterior, we will get a tight Posterior
Predictive. If we have a spread Posterior, we will get a spread
Posterior Predictive. So it's *important* that we have a tool that
allows us to do the *transfer* from the former to the latter.

And now... that's all I understood and I want to write about it. Cheers!


[this video section]: https://youtu.be/R1vcdhPBlXA?list=PLDcUM9US4XdPz-KxHM4XHt7uUVGWWVSus&t=3841
[Statistical Rethinking 2023]: https://www.youtube.com/playlist?list=PLDcUM9US4XdPz-KxHM4XHt7uUVGWWVSus
[Richard McElreath]: https://www.youtube.com/@rmcelreath
[the book]: https://xcelab.net/rm/statistical-rethinking/
[the previous version of the section]: https://www.youtube.com/watch?v=guTdrfycW2Q&t=3443s
