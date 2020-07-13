#!/bin/sh

me="$(readlink -f "$0")"
md="$(dirname "$me")"

# Get credentials from the environment or from a file. Yes, this can be
# improved!
credentials="${GHP_CREDENTIALS:-"$(cat ~/.github/ghp-rebuild)"}"
fqrepo="${GHP_FQREPO:-"$(
      teepee -y "$md/_config.yml" \
         -T '[%= (V("origin") =~ m{github.com/([-\w]+/[-\w]+)}mxs)[0] %]'
   )"}"

curl \
   -u "$credentials" \
   -X POST \
   -H "Accept: application/vnd.github.v3+json" \
   "https://api.github.com/repos/$fqrepo/pages/builds"
