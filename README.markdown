# Blawg

My Blog. Build with Hugo, it's hosted on CloudFlare Workers (not pages).


## Setup Instructions

* Install Node.

* Install Wrangler (to deploy): `npm install -g wrangler`

* Install latest Hugo (to build): <https://github.com/gohugoio/hugo/releases/latest>

```bash
# Example curl snippe to get the latest linux binary and put it in the path. May require restarting terminal.
VERSION=0.147.3 && curl -L https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_${VERSION}_linux-amd64.tar.gz | tar zxf - -C /usr/local/bin/
```

Tangent: Some chatter on how to make GitHub compatible URLs that automatically download the latest version is here: <https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8>. Using `latest` instead of the git tag gets you the correct tag, but doesn't help you if the filename contains a dynamic version number.


## Static and Dynamic

While the goal is to publish everything as static, I wanted to support cross posting to modern social networks like BlueSky and Mastodon, so you may find some dynamic bits here, powered by CloudFlare Workers. Details to follow, once I figure them out.
