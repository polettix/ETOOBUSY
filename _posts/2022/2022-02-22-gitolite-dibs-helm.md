---
title: 'Gitolite image - Helm chart'
type: post
tags: [ gitolite, git, perl ]
comment: true
date: 2022-02-22 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I added a [Helm][] chart to [gitolite-dibs][].

In last post [Gitolite - a dibs repository][] I introduced
[gitolite-dibs][], a repository where I keep the development stuff for
wrapping [Gitolite][] inside a [Docker][] image, aiming at deploying it
with [Kubernetes][].

The sub-directory [helm][subdir] contains the needed parts to build a
[Helm][] chart. Run script `pack.sh` inside to generate a tarball that
is suitable for running `helm`.

The chart is still in a bit of flux. The biggest pain point is managing
the [PersistentVolume][] and the deployment might shift to a
[StatefulSet][] in the future.

All said, it's immediately useable with the following configuration
options in the `values.yaml` file:

- `image`: the usual stuff here, like a `name` that points to the image
  (most probably in a registry) and a `pullPolicy` that does what you
  think.
- `service`: allows setting the details for the service. [Gitolite][] is
  accessible through SSH in this image, so the port is 22 by default.
  It's possible to bind to a specific `node_port` if `type` is set as
  such.
- `volume`: this is the volume where repositories are kept, which is
  also user `git`'s home directory. It's supposed to be a filesystem.
  Available keys are `access_mode` (defaulting to `ReadWriteMany`),
  `size` (defaulting to 10 Gi) and the `storage_class` (defaulting to
  the empty string). It's also possible to enable a section about `nfs`,
  which currently does nothing special apart generate the specification
  for a [PersistentVolume][] automatically in the printed text at the
  end of a deployment via `helm`.
- `config`: this is where [Gitolite][]-specific or less specific stuff
  ends up. It has several sub-sections:
  - `admin_public_key`: the key to associate to the `admin` user, which
    is the first user created and also enabled to do remote management
    through the `gitolite-admin` repository;
  - `host_keys`: there are three sub-keys pointing to the respective
    keys, namely `rsa`, `ecdsa`, and `ed25519`;
  - `sshd_config`: the file `sshd_config` itself;
  - `gitolite_rc`: what will be used as file `~/.gitolite.rc`.

Configurations end up in [ConfigMaps][] (`admin_public_key` and
`gitolite_rc`) and a [Secret][] (`sshd_config` and `host_keys`) for
later tweaking, although it's best to only use `helm` with an updated
local `values.yaml` file at this point.

At the end of the deployment, a file is printed including the YAML for a
[PersistentVolume][], which can be used to create the `git` home volume
separately. Also the management of handing over the same volume to a
different installation is something that has to be addressed manually at
the moment (upgrades in the chart should work fine though).

Enough for today... say safe!

[Perl]: https://www.perl.org/
[Gitolite]: https://gitolite.com/gitolite/
[Docker]: https://www.docker.com/
[Kubernetes]: https://kubernetes.io/
[dibs]: https://github.com/polettix/dibs
[fork]: https://github.com/polettix/gitolite
[gitolite-license]: http://gitolite.com/gitolite/#license
[apache-2.0]: http://www.apache.org/licenses/LICENSE-2.0
[Helm]: https://helm.sh/
[PersistentVolume]: https://kubernetes.io/docs/concepts/storage/persistent-volumes/
[StatefulSet]: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/
[ConfigMaps]: https://kubernetes.io/docs/concepts/configuration/configmap/
[Secret]: https://kubernetes.io/docs/concepts/configuration/secret/
[Gitolite - a dibs repository]: {{ '/2022/02/21/gitolite-dibs/' | prepend: site.baseurl }}
[gitolite-dibs]: https://gitlab.com/polettix/gitolite-dibs
[subdir]: https://gitlab.com/polettix/gitolite-dibs/-/tree/main/helm
