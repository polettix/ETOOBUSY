---
title: Monte Carlo Tree Search - basics
type: post
tags: [ algorithm, monte carlo tree search ]
comment: true
date: 2020-11-09 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> I've been interested into the [Monte Carlo tree search][] algorithm
> lately.

The [Monte Carlo tree search][] is an interesting algorithm that can be
useful when trying to code an AI for a game (like e.g. board games).

The [Wikipedia][] [page][Monte Carlo tree search] does a good job describing
the algorithm; to fix the ideas, though, I'm going to write a quick summary
here, jotting down a few things that were not *immediately clear* at the
beginning. This will hopefully come useful to others... hey future me!

One interesting thing about this algorithm is its relative youth. It seems
to have surged in interest after AlphaGo adopted it within its gamut of
algorithms... and a lot of the material seems to concentrate on how cool
AlphaGo is instead of getting into the details of the algorithm. Or... my
Web-Fu isn't as strong as I wish.

# Steps.... and phases

The algorithm is *normally* divided into four steps, which is fine and good
for implementation.

On the other hand, I think that there are two phases, based on how it works
in general. The basic idea is that we don't know much about where we are in
a specific situation, and we want to *learn* more about our options. To do
this, we need to *study*.

What we have learned so far is kept in a *tree* of our current knowledge. At
the beginning it will not be very accurate - we hope that our knowledge will
improve with more study.

So, I really see two phases in MCTS:

- **Deterministic**: the currently known tree of decisions is traversed
  according to a deterministic algoritm to figure out what part it's better
  to study more. The general spirit here is that we might feel that going
  down one path might be the right way, but yet we keep enough skepticism to
  also probe ways that we consider less rewarding, just in case we had some
  bad luck in studying those alternatives. This phase has a single
  implementation step called *Selection*.
- **Stochastic**: at a certain point, we will reach the *frontier* of our
  current knowledge. We need to study more! To do this, we adopt a Monte
  Carlo strategy, going randomly until we hit some result (e.g. one of the
  players wins) and taking note of what happened (i.e. "learning"
  something). This phase has three steps:
    - **Expansion**: when we are at the frontier (i.e. in a leaf of our current
      tree of knowledge), we might need to decide what to explore next. To
      do this, we *expand* the node adding to it a new leaf for each
      possible move that would be allowed in that node's state. This step
      might not be necessary all times, especially if we hit a leaf node for
      which we have no previous knowledge at all (i.e. we cannot apply the
      *deterministic* part to it);
    - **Simulation**: this is the random study we discussed above, at the core
      of the *stochastic* part. As the [Wikipedia article][Monte Carlo tree
      simulation][] points out, this step might also be called *Rollout* or
      *Playout*.
    - **Backpropagation**: this is the *learning* part, where we go back in our
      tree of knowledge recording what happened in this particular
      simulation.

This is really it in a nutshell!

# Number of players

I had to struggle a bit with understanding how thing worked with multiple
players, although in hindsight I was probably tired when I read about it in
the first place because the [Wikipedia post][Monte Carlo tree search] is
actually clear to this regard.

Anyway.

The algorithm can be adapated to whatever number of players, even
solitaires. As I understood it, the only part where the number of different
players actually matters is during the last step, i.e. the *backpropagation*
where we learn some information about our simulation.

In particular, assuming that we are always able to associate a node in the
tree with one single player that has to decide a move:

- the specific node will have its *win* counts incremented by 1 if and only
  if the simulation led to the victory of the associated player;
- the specific node will have its *win* counts incremented by $1 / N$ (where
  $N$ is the number of players) in case of a draw in the simulation.

Points-assignment refinements might chage on a game-to-game situation (e.g.
if a 3-players game might yield a shared victory between two of the three
players), but the basic idea is the one above.

This adapts well to any number of players, and it also simplifies the
*selection* step because each node will contain data as *seen* from the
point of view of the player that has to place a move.

Yes, this took me a bit to understand 😅


# Conclusion

This barely scratched the surface of the algorithm, I'd like to move towards
some kind of implementation to learn it better. Until next time... stay
safe!

I'll leave this post with a useful link to an article I want to investigate
more in depth: [A survey of Monte Carlo tree search methods (2012)][survey],
by Cameron Browne , Edward Powley , Daniel Whitehouse , Simon Lucas , Peter
I. Cowling , Stephen Tavener , Diego Perez , Spyridon Samothrakis , Simon
Colton, et al. The article can be found in various places, I also keep a
[local copy here][], mirrored from [this copy on diego-perez.net][dpnet].

[Monte Carlo tree search]: https://en.wikipedia.org/wiki/Monte_Carlo_tree_search
[Wikipedia]: https://en.wikipedia.org/
[survey]: https://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.297.3086
[local copy here]: {{ '/assets/other/MCTSSurvey.pdf' | prepend: site.baseurl }}
[dpnet]: http://www.diego-perez.net/papers/MCTSSurvey.pdf
