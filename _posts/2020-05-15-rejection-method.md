---
title: Rejection method
type: post
tags: [ maths, probabilities, sampling ]
series: 'Transforming Randomization'
comment: true
date: 2020-05-15 07:00:00 +0200
published: true
mathjax: true
---

**TL;DR**

> Let's take a closer look at the [rejection method][].

In [A 4-faces die from a 6-faces die][] we used the *rejection method*
to generate a D4 die using a D6: just roll it, and remove whatever does
not fit your needs.

It turns out that this idea can be generalized to generate more complex
samples, based on *whatever* probability density function.

The following example describes a probability density function, with the
non-trivial constraint that its possible values on the $x$ axis are
limited between $0$ and $a$:

![densify function]({{ '/assets/images/rejection/density.png' | prepend: site.baseurl }})

Let's simplify, and encapsulate this *complicated* function within
something simpler:

![containing function]({{ '/assets/images/rejection/containing-function.png' | prepend: site.baseurl }})

Of course this is not a probability density, but it's easy to rescale it
and get one, i.e. a uniform distribution between $0$ and $a$:

![containing function]({{ '/assets/images/rejection/uniform-density.png' | prepend: site.baseurl }})

# Let's give it a try

Now, let's generate a random number with this uniform density: as a
matter of fact, we're generating a number on the $x$ axis that is within
the range where our original density $p(x)$ is non-zero:

![containing function]({{ '/assets/images/rejection/x-random-draw.png' | prepend: site.baseurl }})

On the $y$ dimension, this lets us isolate a segment corresponding to
that specific value of $x$ and extending from $0$ up to the total height
of the containing rectangle:

![containing function]({{ '/assets/images/rejection/threshold-establishing.png' | prepend: site.baseurl }})

We can now generate another random number *within* this segment, again
using a uniform distribution:

![containing function]({{ '/assets/images/rejection/y-random-draw.png' | prepend: site.baseurl }})

Now it's time to *accept* this random draw or *reject* it. Whatever goes
*above* the target $p(x)$ will be *rejected*, whatever goes under is
*accepted*. In this case, we have a rejection.

![containing function]({{ '/assets/images/rejection/rejection.png' | prepend: site.baseurl }})

Time for a new try, then!

# Let's try again

Like before, we first generate a value on the $x$ dimension:

![containing function]({{ '/assets/images/rejection/x-random-draw-2.png' | prepend: site.baseurl }})

This gives us a new vertical segment:

![containing function]({{ '/assets/images/rejection/threshold-establishing-2.png' | prepend: site.baseurl }})

At this point, we can draw another uniform value in the vertical range:

![containing function]({{ '/assets/images/rejection/y-random-draw-2.png' | prepend: site.baseurl }})

It seems that we were lucky this time: the value generated is *below*
the corresponding value of $p(x)$ for the same $x$, so we *accept* this
draw.

![containing function]({{ '/assets/images/rejection/acceptance.png' | prepend: site.baseurl }})


# Will it work?

Without delving in a formal demonstration, it's easy to see that this
technique is going to work. Doing a lot of attempts, we end up with
something like this:

![containing function]({{ '/assets/images/rejection/many-attempts.png' | prepend: site.baseurl }})

On the other hand, let's remember that all the red crosses are rejected,
so we can just as well ignore them and obtain this:

![containing function]({{ '/assets/images/rejection/accepted-samples.png' | prepend: site.baseurl }})

This, indeed, is very close to drawing samples from the target $p(x)$,
isn't it?


[A 4-faces die from a 6-faces die]: {{ '2020/05/11/d6-to-d4' | prepend: site.baseurl }}
