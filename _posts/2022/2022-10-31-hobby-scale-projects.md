---
title: Software Tools for Hobby-Scale Projects
type: post
tags: [ coding ]
comment: true
date: 2022-10-31 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> An interesting page: [Software Tools for Hobby-Scale Projects][].

By following links through the Internet *the old way*, I landed on an
interesting page: [Software Tools for Hobby-Scale Projects][].

Just one teaser from the page:

> I used the following criteria to select the tools:
>
> - They cost less than a coffee or are free.
> - They are quickly learned.
> - They allow you to accomplish a single task in a short amount of time
>   (such as a Sunday afternoon)
> - They are less focused on the needs of long-term projects
>   (scalability, speed, etc.) and more focused on ease of use and
>   prototyping speed.

As already pointed out in the page itself, MyJSON is no longer active.
On the other hand, I discovered that [MyJSONs][] is active as of end of
October 2022, so I guess this saves the day for the moment.

Using it from the command line with a few common tools seems
straightforward, let's see a few examples:

```shell
ENDPOINT='https://www.myjsons.com'

# generate some data
json_src='/tmp/somefile.json'
cat >"$json_src" <<'END'
{
   "hey": "you",
   "values": [ 1, 2, 3 ]
}
END

# Add an item, get the code back
code="$(
    curl -si "$ENDPOINT" --data-urlencode "json@$json_src" \
    | sed -ne 's#^Location.*/\([a-fA-F0-9]*\).*#\1#p'
)"

# retrieve the data
json_data="$(curl -s "$ENDPOINT/v/$code")"

# update the data
updated_json_data="$(
    printf %s "$json_data" \
    | jq '{"hey": "folks", "values": .values}'
)"
curl -s "$ENDPOINT/e/$code" --data-urlencode "json=$updated_json_data"
```

Stay crafty!


[Perl]: https://www.perl.org/
[Software Tools for Hobby-Scale Projects]: https://rickcarlino.com/2019/software-tools-for-hobby-sized-projects.html
[MyJSONs]: https://www.myjsons.com
