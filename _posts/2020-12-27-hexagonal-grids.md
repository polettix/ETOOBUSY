---
title: Hexagonal grids
type: post
tags: [ coding, graph ]
comment: true
date: 2020-12-27 10:52:41 +0100
mathjax: true
published: true
---

**TL;DR**

> Some words on hexagonal grids, and a pointer to something **serious**:
> [Hexagonal Grids][amit-hexagonal] on [Red Blob Games][].

In recent post [The Definitive Conway's Game of Life][] I made a quick and
vague reference to using a *hexagonal grid* for playing [Conway's Game of
Life][]. So I thought that maybe some additional hints might be useful as
well.

In that specific challenge, a *simple* representation of the whole grid
based on two coordinates was sufficient:

- take any hexagon in your grid and consider it your origin;
- that hexagon has three pairs of opposite sides;
- choose one pair and consider that as your $X$ dimension. Make it increase
  as you move right (or up, if the two sides are stacked vertically);
- choose a different pair and consider that as your $Y$ dimension. Again,
  make it increase with the same rules as above.

This is actually all you need. From the origin, you can directly reach four
of the six adjacent cells by only changing one unit (positive or negative)
in one of the dimensions. As an example, assume that the grid is such that
hexagons have a flat side on the up/down direction (which is actually
*not* what was happening in the challenge), we might choose $X$ and $Y$ as
follows:

```
^ Y
|
|                        >--------<
|             >--------<  ( 0,  1)  >--------<
|         --<  (-1,  0)  >--------<            >--
|             >--------<  ( 0,  0)  >--------<
|         --<            >--------<  ( 1,  0)  >--
|             >--------<  ( 0, -1)  >--------<
|                        >--------<
          ----
              \--------- 
                        \----------
                                   \-------->
                                            X
```

Now we're left with the two missing cells, one right-up and another one
left-down.

Starting from the origin, there are two ways to reach the right-up cell:

- go right-down first (increase in $X$ only, landing on $(1, 0)$), then up
  one step (increase in $Y$ only, landing on $(1, 1)$);
- go up first (increase in $Y$ only, landing on $(0, 1)$, the right-down
  (increase in $X$ only, landing on $(1, 1)$).

Both way are consistent: the right-up cell is at $(1, 1)$, i.e. it is
obtained by increasing one single step in both dimensions.

It's easy to see that the same can be done for left-down, yielding $(-1,
-1)$, i.e. a *decrease* in both dimensions.

So, we're left with the following *displacements* for all cells adjacent to
the origin:

```
^ Y
|
|                        >--------<
|             >--------<  ( 0,  1)  >--------<
|         --<  (-1,  0)  >--------<  ( 1,  1)  >--
|             >--------<  ( 0,  0)  >--------<
|         --<  (-1, -1)  >--------<  ( 1,  0)  >--
|             >--------<  ( 0, -1)  >--------<
|                        >--------<
          ----
              \--------- 
                        \----------
                                   \-------->
                                            X
```


Expanding this to the whole plane... we get a unique pair of $(x, y)$
coordinates for each cell. It's also easy to *see* that this is equivalent
to a square grid, where the neighbors of any cells are the four adjacent
ones (in the up, down, left, and right directions), *plus* the two diagonal
ones on the right-up and the left-down directions. The other two cells in
the other diagonal... are distant, sorry! The following picture marks with
asterisks the cells in this mapping that are considered *adjacent* to the
origin:

```
               |            |
     (-1,  1)  | *( 0,  1)* | *( 1,  1)*
               |            |
    -----------+------------+-----------
               |            |
    *(-1,  0)* |  ( 0,  0)  | *( 1,  0)*
               |            |
    -----------+------------+-----------
               |            |
    *(-1, -1)* | *( 0, -1)* |  ( 1, -1)
               |            |
```

In that challenge, though, the hexagons are arranged with flat sides on the
left-right direction instead. Again, it's easy to choose two dimensions and
extend what we explained above, e.g. yielding this arrangement for the
displacement of cells adjacent to the origin:

```
               ( 0,  1)          ( 1,  1)

      (-1,  0)          ( 0,  0)          ( 1,  0)

               (-1, -1)          ( 0, -1)
```

Again... it's the same mapping on the square grid: adjacents are all four in
the up, down, left, and right, plus the two diagonals in the right-up and
left-down directions.

So much for the challenge. If you *really* want to understand what's going
on with the hexagons... your next stop *MUST* be [Hexagonal
Grids][amit-hexagonal] from [Red Blob Games][]!


[amit-hexagonal]: https://www.redblobgames.com/grids/hexagons/
[The Definitive Conway's Game of Life]: {{ '/2020/12/24/conway-general/' | prepend: site.baseurl }}
[Conway's Game of Life]: {{ '/2020/04/23/conway-life/' | prepend: site.baseurl }}
[Red Blob Games]: https://www.redblobgames.com/
