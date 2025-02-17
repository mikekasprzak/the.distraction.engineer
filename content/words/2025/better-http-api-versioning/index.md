+++
title = "Better HTTP API versioning with VX Versioning"
date = "2025-02-13T18:13:00.308Z"
summary = "hey I'm cool"
+++

Summary?


## The semantics of versioning with SemVer

[Semantic Versioning](https://semver.org/) (SemVer) is a popular way of describing change in a project. SemVer follows a simple grammar: {{<highlight bash "hl_inline=true">}}{MAJOR}.{MINOR}.{PATCH}{{</highlight>}}, replacing each {{<highlight bash "hl_inline=true">}}{variable}{{</highlight>}} with a number. A project could describe its version as `1.0.2` or `v2.11.0-rc2`. Both of these are valid versions. To compare them as "semantic versions" though, you trim off the other stuff (i.e. `v2.11.0-rc2`&nbsp;→&nbsp;`2.11.0`).

Semantic Versioning is intuative to a point. Without knowing the grammar, most users will correctly assume bigger numbers are newer and "better". They might stumble with their first `1.11.0`&nbsp;>&nbsp;`1.3.0` situtation, but that's it. As an author though, even if you know the grammar, it's not intuative what should change.

![Pride Versioning. Bump MAJOR when you are proud of the release, MINOR for ordinary releases, and PATCH for shameful releases](pridever.png "If you're like me, you might have used [Pride Versioning](https://pridever.org) without realizing it")

It's not

If say you were making a video game, then arbitrarily changing version numbers by "feeling" probably wont hurt anybody. As long as your latest version number is newer, App stores wont give you any trouble. That said, if your project ever became a dependency, then following strict versioning rules will help those downstream of you.

The [Semantic Versioning 2.0.0 specification](https://semver.org/) provides some excellent guidance.

An [Application Programming Interface](https://en.wikipedia.org/wiki/API) (API) is how our software can use other software. If the API was to change, it's possible our software may stop working.


### The social contract of MAJOR versions

e


## VX Versioning

VX versioning has one rule:

> If an API _may_ break, use an `x`.

That's it.

VX is an abreviation for "Version eXperimental". It's something I started doing back in 2016


```html
api.twitch.tv/kraken/...
api.twitch.tv/helix/... - <div>no guarentee ?</div>
```


Inspired by Anthony Fu's [Epoch Semantic Versioning](https://antfu.me/posts/epoch-semver), this is my take on another versioning headache.
