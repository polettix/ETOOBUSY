---
title: Blog posts rearrangement
type: post
tags: [ blog, jekyll ]
comment: true
date: 2022-11-13 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I rearranged the posts in this blog inside sub-directories, I hope I
> didn't break anything...

This year I only wrote 4 times about this [blog][] so far, which makes
this the fifth. I guess it's a fair share. Well, at least *I hope*.

Going into the [_posts sub-directory in GitHub][ghposts] I saw this:

![Message from github: Sorry, we had to truncate this directory to 1,000 files. 53 entries were omitted from the list.]({{ '/assets/images/20221113-gh-error.png' | prepend: site.baseurl }})

This made me both proud (*way over 1000 entries, yay!*) and painfully
aware that I should think better when setting up things that might *grow
in time*. You know, like logs or blog posts.

It so happened that [the particular assembly of technologies
here][about] made addressing this quite straightforward. I mean, as much
straighforward as just doing this:

```
cd _posts
mkdir 2019 2020 2021
mv 2019-* 2019
mv 2020-* 2020
mv 2021-* 2021
git add .
git commit -m 'Move older posts into sub-folders, by year'
```

I hope I did not break anything... time will tell. A few random checks
seem to be fine though, *in my computer...*

Stay safe folks!

[blog]: {{ '/tagged/#blog' | prepend: site.baseurl }}
[about]: {{ '/about/' | prepend: site.baseurl }}
[ghposts]: https://github.com/polettix/ETOOBUSY/tree/6c862acb3862e61827842e804cd595b6595ce0c5/\_posts

