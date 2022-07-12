#!/bin/sh

me="$(readlink -f "$0")"
md="$(dirname "$me")"

# Get credentials from the environment or from a file. Yes, this can be
# improved!
#
# NOTE NOTE NOTE
#
# - use a Personal Access Token with scope "repo" at
#   https://github.com/settings/tokens
#
# - NO, "repo_public" WILL NOT cut it, full "repo" is needed
#
# - just the token, no username or anything in the file or env variable
#
# Example:
#
#     GHP_CREDENTIALS=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
#
# More: https://docs.github.com/en/rest/pages#request-a-github-pages-build
#
credentials="${GHP_CREDENTIALS:-"$(cat ~/.github/ghp-rebuild)"}"



fqrepo="${GHP_FQREPO:-"$(
      teepee -y "$md/_config.yml" \
         -T '[%= (V("origin") =~ m{github.com/([-\w]+/[-\w]+)}mxs)[0] %]'
   )"}"

$PRE curl $POST \
   -X POST \
   -H "Accept: application/vnd.github+json" \
   -H "Authorization: token $credentials" \
   "https://api.github.com/repos/$fqrepo/pages/builds"
