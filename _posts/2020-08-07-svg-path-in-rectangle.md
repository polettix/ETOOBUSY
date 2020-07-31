---
title: SVG path in a rectangle
type: post
tags: [ perl, svg ]
comment: true
date: 2020-08-07 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Where we try to fit something in a rectangle, for SVG.

After figuring out a bunch of things about [#svg][], it's time to
understand how we can fit *something* inside a rectangle.

As an example, after having found what is the bounding box for a path,
we might want to scale and move it to a specif rectangle... let's see
how.

We will consider the following path:

```text
m 7.429860,29.751745 l 4.368800,0.101600 l 0.000000,-10.837344
l 6.265340,0.101600 l 0.101600,-3.725337 l -4.842940,0.000000
l 0.000000,-2.878669 l 6.807210,0.237067 l 0.440270,-6.604007
l -13.140280,0.000000 z
```

that is the following image:

![Path]({{ '/assets/images/svg-path-in-rectangle/F-uppercase.svg' | prepend: site.baseurl }})

The width is about $13.140$ units and the height is about $23.707$
units. I cheated because I lookd for them in [Inkscape][], but we now
how to calculate the bounding box! ([#svg][] posts help here). Overall,
then, the path has the following characteristics:

$$
\mathbf{P_{path}} = \begin{bmatrix}
x_{path} \\
y_{path}
\end{bmatrix} = \begin{bmatrix}
7.430 \\
6.147
\end{bmatrix}\\
\mathbf{\Sigma_{path}} = \begin{bmatrix}
W_{path} \\
H_{path}
\end{bmatrix} = \begin{bmatrix}
13.140 \\
23.707
\end{bmatrix}
$$


Now, suppose that we want to generate a SVG file where we want to fit
this path in a rectangle:

$$
\mathbf{P_{target}} = \begin{bmatrix}
x_{target} \\
y_{target}
\end{bmatrix} = \begin{bmatrix}
10 \\
10
\end{bmatrix} \\
\mathbf{\Sigma_{target}} = \begin{bmatrix}
W_{target} \\
H_{target}
\end{bmatrix} = \begin{bmatrix}
40 \\
90
\end{bmatrix}
$$

We will refer to a A6 sheet with a view box that has $1$ unit per
millimiter:

![Initial rectangle]({{ '/assets/images/svg-path-in-rectangle/stage1.svg' | prepend: site.baseurl }})

Let's start!

# Fitting in a rectangle, practically

From a practical standpoint, we will have to do two operations:

- scale our image so that its width/heigth fit in the size of the target
  rectangle;
- translate the scaled picture to place it in the target position.

Both operations can be done through the `transform` operation in SVG.

## Scaling

Scaling is easy using the `matrix` transformation: it's a $2 \times 2$
matrix where we just fill in two values, like this:

$$
S = \begin{bmatrix}
S_x & 0 \\
0 & S_y
\end{bmatrix}
$$

where $S_x$ and $S_y$ are, respectively, the scaling factors in the $X$
and the $Y$ axes.

If we want to scale the path, we will have to make sure that the width
and the height will match the rectangle's size. This means that we would
have to apply the following scaling factors to the initial path:

$$
S_x = \frac{W_{target}}{W_{path}} = \frac{40}{13.140} \approx 3.044 \\
S_y = \frac{H_{target}}{H_{path}} = \frac{90}{23.707} \approx 3.796
$$

If we keep these values, the path will be stretched in the $Y$ axis
because the scaling factor is higher. Hence, we can do one of two
things:

- keep values as they are and accept the stretching
- take the lower of the two values, keep the *aspect ratio* and allow
  for some "waste" of space in the vertical direction.

In the first case, the path ends up filling the whole rectangle, i.e.
the bounding box of the scaled path would be the same size as the target
rectangle.

In the second case, instead, we will end up with a bounding box that has
the same width as the target rectangle, but a lower height.

In general, the bounding box changes as follows:

$$
\mathbf{\Sigma_{transformed}} = \begin{bmatrix}
W_{transformed} \\
H_{transformed}
\end{bmatrix} = \mathbf{S} \cdot \mathbf{\Sigma_{path}}
= \begin{bmatrix}
S_x && 0 \\
0 && S_y
\end{bmatrix} \cdot \begin{bmatrix}
W_{path} \\
H_{path}
\end{bmatrix}
$$

## Translating

Translating is done using the `translate` transformation. The process
that we will apply will be that:

- first, we will translate the path to have its *initial corner* go to
  the origin;
- then, we will apply the scaling;
- last, we will move the *initial corner* from the origin to its target
  destination.

The first translation is easy, it's sufficient to consider the opposite
of $\mathbf{P_{path}}$:

$$
\mathbf{T_1} = -\mathbf{P_{path}}
$$

The second translation will have to take into account that scaling might
stretch or not the path. If it stretches it, then the final bounding box
will have the same size as the target rectangle, so it's sufficient to
move the origin to the target rectangle's *initial corner*. Otherwise,
it's better to center the final bounding box inside the rectangle.

Overall, we have that the second translation will be:

$$
\mathbf{T_2} = \mathbf{P_{target}} +
\frac{1}{2} \cdot (\mathbf{\Sigma_{target}} - \mathbf{\Sigma_{transformed}})
$$

# Let's do it!

The transformations can be applied "inline" to the path.

## Stretching

In this case, the transformations will be:

- translation:

$$
\mathbf{T} = \begin{bmatrix}
-7.430 \\
-6.147
\end{bmatrix}
$$

- scaling matrix:

$$
\mathbf{S} = \begin{bmatrix}
3.044 & 0 \\
0 & 3.796
\end{bmatrix}
$$

- translation:

$$
\mathbf{T} = \begin{bmatrix}
10 \\
10
\end{bmatrix}
$$

The transformation is applied to a group that includes the path; also,
remember that transformations are applied from right to left!

```xml
<g transform="translate(10 10) scale(3.044 3.796) translate(-7.43 -6.147)">
   <path style="fill:none;stroke:#000;stroke-width:0.1px"
      d="m 7.429860,29.751745 l 4.368800,0.101600   l 0.000000,-10.837344 l 6.265340,0.101600
         l 0.101600,-3.725337 l -4.842940,0.000000  l 0.000000,-2.878669  l 6.807210,0.237067
         l 0.440270,-6.604007 l -13.140280,0.000000 z" />
</g>
```

The result is shown in the following picture.

![Stretching]({{ '/assets/images/svg-path-in-rectangle/stage2.svg' | prepend: site.baseurl }})

## Keeping the aspect ratio

In this case, the transformations will be:

- translation:

$$
\mathbf{T} = \begin{bmatrix}
-7.430 \\
-6.147
\end{bmatrix}
$$

- scaling matrix:

$$
\mathbf{S} = \begin{bmatrix}
3.044 & 0 \\
0 & 3.044
\end{bmatrix}
$$

- translation:

$$
\mathbf{T} = \begin{bmatrix}
10 \\
18.918
\end{bmatrix}
$$

The transformation is applied to a group that includes the path; also,
remember that transformations are applied from right to left!

```xml
<g transform="translate(10 18.918) scale(3.044 3.044) translate(-7.43 -6.147)">
   <path style="fill:none;stroke:#000;stroke-width:0.1px"
      d="m 7.429860,29.751745 l 4.368800,0.101600   l 0.000000,-10.837344 l 6.265340,0.101600
         l 0.101600,-3.725337 l -4.842940,0.000000  l 0.000000,-2.878669  l 6.807210,0.237067
         l 0.440270,-6.604007 l -13.140280,0.000000 z" />
</g>
```

The result is shown in the following picture.

![Keep aspect ratio]({{ '/assets/images/svg-path-in-rectangle/stage3.svg' | prepend: site.baseurl }})

# Conclusions

Doing some transformations on SVG paths to set them in a specific place
is not difficult but requires some attention and some decisions:

- whether to preserve the aspect ratio or not
- whether to center the path in the target rectangle or not
- care to apply translations and scaling in the right order
- doing transformations to a group allows separating the concerns... but
  it's not strictly necessary (i.e. the `transform` part might be put
  directly in the `path`).

Cheers!


[#svg]: {{ '/tagged/#svg' | prepend: site.baseurl }}
[Inkscape]: https://inkscape.org/
