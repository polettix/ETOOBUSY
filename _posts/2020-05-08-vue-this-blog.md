---
title: Vue this blog
type: post
tags: [ javascript, vuejs, jekyll, github, blog ]
comment: true
date: 2020-05-08 07:00:00 +0200
published: true
mathjax: false
---

**TL;DR**

> Where I try to use [Vue.js][] inside this very blog.

Well... this is totally going to be a documentation of my on-line effort
to use [Vue.js][] inside this very page.

# Get the software

First thing I did is place release 2.6.11 in the [local
repository][local-fue] (together with the [minified
version][local-vue-min], just if everything works as I hope). I got them
from the official links in the [getting started section of the
introduction][vue-getting-started]:

- [debug-friendly version][vue]
- [minified version][vue-min]

I thought it better to leverage a local copy because [GitHub Pages][]
should have no problem delivering one additional file, and in this way
I'm avoiding any issue related to [Content Security Policy][CSP].

# Put the software in the page

Fortunately, Markdown is HTML-friendly, so I can just put the following
inline:

```html
<script src="{{ '{{' }} '/assets/js/vue.js'
    | prepend: site.baseurl
    | prepend: site.url }}">
</script>
```

Actually, I'm going to include it right here, but you can't see it
unless you take a look at the page source.

<script src="{* link assets/js/vue.js *}"></script>

OK, we're set at this point.

# So let's try it!

Now it's time for the code, I'll take it from the [Vue.js Hello World
Example][], with minimal changes to the style and message:

```html
  <div id="app" style="border: 1px solid green; padding: 1em;">
    This says it all -->[{{ '{{' }} message }}]
  </div>

  <script>
    var app = new Vue({
      el: '#app',
      data: {
        message: 'Hello Folks, it works!'
      }
    })
  </script>
```

Here comes the `div`:

<div id="app" style="border: 1px solid green; padding: 1em;">
  This says it all -->[{{ '{{' }} message }}]
</div>

If you see the message `Hello Folks, it works!` inside the brackets,
then it's working!

Here comes the `script`, which you will not see...

<script>
  var app = new Vue({
    el: '#app',
    data: {
      message: 'Hello Folks, it works!'
    }
  })
</script>

# Watch out for double curlies!

While the above works, there's surely one thing to watch out, i.e. the
use of double braces which are used both by [Jekyll][] and [Vue.js][] to
mark *stuff* to act on. Hence, whatever you want to *arrive* to
[Vue.js][] has to be outsmarted, like this:

```text
{{ '{{ "{{"' }} }} vue_stuff }}
```

The first section is consumed by [Jekyll][] (actually, by [Liquid][]) to
just insert a string with a pair of opening braces, so after the
server-side rendering by [Jekyll][] the page ends up with this:

```
{{ "{{" }} vue_stuff }}
```

At this point, [Vue.js][] can kick in and do its magic.

For a *complicated* web application with lots of [Vue.js][] inserts it
can become... tedious 🙄 This is why you might also want to look for
some alternatives, e.g. what is suggested by [Jekyll][]'s
[documentation][jekyll-docs-tags]:

> Jekyll processes all Liquid filters in code blocks
>
> If you are using a language that contains curly braces, you will
> likely need to place `{{ "{%" }} raw %}` and `{{ "{%" }} endraw %}`
> tags around your code. Since Jekyll 4.0 , you can add
> render_with_liquid: false in your front matter to disable Liquid
> entirely for a particular document.

# What do you think?

I think this opens up a lot of possibilities in terms of doing
moderately dynamic stuff. What do **you** think?


[Vue.js]: https://vuejs.org/
[local-vue]: {{ '/assets/js/vue.js' | prepend: site.baseurl | prepend: site.url }}
[local-vue-min]: {{ '/assets/js/vue.min.js' | prepend: site.baseurl | prepend: site.url }}
[vue-getting-started]: https://vuejs.org/v2/guide/
[vue]: https://cdn.jsdelivr.net/npm/vue/dist/vue.js
[vue-min]: https://cdn.jsdelivr.net/npm/vue
[GitHub Pages]: https://pages.github.com/
[CSP]: https://en.wikipedia.org/wiki/Content_Security_Policy
[Vue.js Hello World Example]: https://codesandbox.io/s/github/vuejs/vuejs.org/tree/master/src/v2/examples/vue-20-hello-world
[Jekyll]: https://jekyllrb.com/
[Liquid]: https://github.com/Shopify/liquid/wiki
[jekyll-docs-tags]: https://jekyllrb.com/docs/liquid/tags/
