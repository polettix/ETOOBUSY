---
title: Troubleshooting Pods and Containers
type: post
tags: [ kubernetes, docker, container, toolbox ]
comment: true
date: 2019-09-29 19:33:44 +02:00
---

Sometimes looking at a few logs provided by [Docker][] or [Kubernetes][]
is not enough. Sometimes you have to take a deep breath and dive down
into the running container.


## Before We Start...

We will deal with both command-line tool `docker` (from [Docker][]) and
`kubectl` (from [Kubernetes][]), which most of the time will require
some command-line parameters. Here is our convention:

- `$c_nid` indicates a container name or identifier, used by `docker`.
  You can get this using `docker ps` and looking at the first
  (identifier) or last (name) column, whatever you find easier.

- `$ns` indicates a [Kubernetes][]'s namespace (defaulting to `default`,
  usually), used by `kubectl`.

- `$pod` indicates a Pod's name, used by `kubectl`. Please remember
  that a specific Pod name is only valid within a specific namespace.
  You can get the name of the Pod you're after with command `kubectl get
  pod -n "$ns"` or `kubectl get pod --all-namespaces` if you don't know
  the namespace.

- `$c_name` indicates a container's name inside a Pod, used by
  `kubectl`. For Pods that only hold one container this parameter is
  usually not necessary. A container's name is only valid within a
  specific Pod, you can get a list of container names inside a Pod with
  the following command:

{% highlight bash %}
kubectl get pod "$pod_name" -n "$ns" \
   -o jsonpath='{.status.containerStatuses[].name}'
{% endhighlight %}

For [Kubernetes][]'s variables described above, you can also use the
interactive terminal tool [K9s][] (there is also [a post about
K9s][k9s-post] here).


## The Basic Command: `exec`

`exec` is at the heart of your "intrusion" capabilities, so let's take a
closer look.

**The commands and examples in this section assume that the invoked
programs (`/bin/sh` or `/bin/bash` in the examples) are part of the
container's filesystem.** See section [Bringing Some
Tools](#bringing-some-tools) below if you need to put either one in the
container's filesystem.

### Docker

At the most basic level, you can ask [Docker][]'s `docker` to execute a
program inside a running container. This means that you can invoke a
shell inside the container, provided that you also pass command-line
parameters `-i` and `-t` to get an interactive terminal. So, as a
starting point, just try this:

{% highlight bash %}
docker exec -it "$c_nid" /bin/sh
{% endhighlight %}

If you feel brave and prefer [bash][] instead, just go for it:

{% highlight bash %}
docker exec -it "$c_nid" /bin/bash
{% endhighlight %}

You can also read all documentation about [`docker exec`][docker-exec].

### Kubernetes

[Kubernetes][]'s `kubectl exec` mirrors [Docker][]'s `docker exec`
command of course, with the added twist that you have to at least
provide a Pod identifier and, in case the Pod holds multiple containers,
a container identifier as well.  And please don't forget to include the
namespace if it's different from the default one!

{% highlight bash %}
kubectl exec -it "$pod" -n "$ns" -c "$c_name" /bin/sh
{% endhighlight %}

If you happen to have [K9s][] (and [there are no reasons you
shouldn't][k9s-post]), running a shell is very straightforward:

- select the Pod you are interested into
- hit `s` (for *shell*)
- if asked, select a container

and enjoy your shell.

[K9s][] restricts this to trying to run `/bin/bash` and a simple
`/bin/sh` as a fallback, but this is what you probably want most of the
times.

## Bringing Some Tools

If you have to do troubleshooting, I sincerely wish you to find all
needed tools inside the container's filesystem. In this way, you only
need to enter the container as explained in the previous section and
start investigating.

Alas, this is not always the case. There are different things that you
can do at this point, e.g. enter the container and install the tools
from the system, if possible. On the other hand, if you want to reduce
your impact as much as possible, it's better to avoid this route (e.g.
you might install a tool that automagically solves an issue, and end up
with a container that has nothing to be investigated).

For this reason, having a [#toolbox][] of portable tools (e.g.
statically compiled) can be very, very handy. You can compile these
tools yourself, or look around in the Internet (e.g. I found
[andrew-d/static-binaries][andrew-d] and
[yunchih/static-binaries][yunchih] useful in the past, as well as some
*google*-ing around).

As a last consideration, in case the target container does not contain a
shell, you can use the hints below to bring one inside its filesystem
(e.g. [Busybox][] contains such a shell, as explained
[in this post][busybox-post]).

### Docker

To copy files into a running container you can use the *nice* approach or
the *brute force*.

The *nice* approach consists in the `cp` sub-command provided by `docker`:

{% highlight bash %}
docker cp localfile "$c_nid":/path/to/container/directory
{% endhighlight %}

You can also [read all details about `docker cp`][docker-cp].

The *brute force* approach consists in fiddling with the container's
filesystem directly from the host. This is not a route I would suggest
because it involves black magic, but you're the owner of your stuff. The
first thing to do is to find the container's process identifier:

{% highlight bash %}
pid="$(docker inspect --format '{% raw %}{{ .State.Pid }}{% endraw %}' "$c_nid")"
{% endhighlight %}

(see e.g. [docker-pid][]).

Once you have the pid (in our example, in variable `$pid`), the root
filesystem of the target container can be found at the *magic* location
`/proc/$pid/root`. You will probably need to become `root` to access it,
but whatever.

At this point, it's a matter of copying files in the host's filesystem:

{% highlight bash %}
sudo cp localfile "/proc/$pid/root/path/to/container/directory"
{% endhighlight %}

Note that sometimes you might be out of luck even in doing such a
low-level action: some containers are started with a *read-only*
filesystem, and you can't copy anything inside them. I haven't dug
further, but I can only guess it's best to adopt other strategies to
investigate these containers.

### Kubernetes

Much like `docker`, `kubectl` also has a `cp` command that allows you to
copy files from the local machine towards a Pod's container. The generic
syntax is the following:

{% highlight bash %}
kubectl cp -c "$c_name" localfile "$ns"/"$pod_name":/path/to/container/dir
{% endhighlight %}

This command is not exactly the same as `docker`'s though. In
particular, due to the fact that `localfile` and the container might be
in different hosts, a simple `cp -a` will not be possible. This is why
[Kubernetes][] creates a tar archive of the file/files to transfer, move
the archive inside the container and then expand it to the destination;
for this reason, it needs to have `tar` installed inside the container.

If this is not the case, the next best move is:

- find the IP address of the worker node running the Pod:

{% highlight bash %}
worker="$(kubectl get pod "$pod_name" -n "$ns" -o jsonpath='{$.status.hostIP}')"
{% endhighlight %}

- copy the file in the worker node, e.g. (assuming the `scp` works out
  of the box):

{% highlight bash %}
scp localfile "$worker":/tmp/localfile
{% endhighlight %}

- find the docker identifier of the container:

{% highlight bash %}
c_nid="$(kubectl get pod "$pod_name" -n "$ns" \
   -o jsonpath="{.status.containerStatuses[?(@.name=='$c_name')].containerID}" \
   | sed -e 's#^docker://##')"
printf '%s\n' "$c_nid"
{% endhighlight %}

- leverage any of the commands explained in the previous subsection
  about copying files via `docker` (e.g. using `docker cp` or the *brute
  force* approach). As an example, you might even drive it directly from
  the node where you are:

{% highlight bash %}
ssh "$worker" docker cp /tmp/localfile "$c_nid":/path/to/container/directory
{% endhighlight %}

(add `sudo` in front of `docker cp` if needed).

## Wrap Up

If you came here with specific hints about doing troubleshooting, you
were probably out of luck. On the other hand, this post explained a few
ways to enable you doing your investigations... so I hope it's still
useful.


[Docker]: https://www.docker.com/
[Kubernetes]: https://kubernetes.io/
[k9s-post]: {{ '/2019/09/29/k9s/' | prepend: site.baseurl | prepend: site.url }}
[Busybox]: https://busybox.net/
[busybox-post]: {{ '/2019/09/29/busybox-multipurpose-executable/' | prepend: site.baseurl | prepend: site.url }}
[K9s]: https://github.com/derailed/k9s
[#toolbox]: {{ '/tagged/#toolbox' | prepend: site.baseurl | prepend: site.url }}
[andrew-d]: https://github.com/andrew-d/static-binaries
[yunchih]: https://github.com/yunchih/static-binaries
[docker-cp]: https://docs.docker.com/engine/reference/commandline/cp/
[docker-exec]: https://docs.docker.com/engine/reference/commandline/exec/
[docker-pid]: https://gist.github.com/petersellars/ffa2d63c20e881302493
[bash]: https://www.gnu.org/software/bash/
