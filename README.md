# homebrew-sde

Homebrew tap for [sde](https://github.com/alexs60/safe-sde) — role-separated
container isolation for AI-assisted development.

## Install

```sh
brew tap alexs60/sde
brew install sde
```

Then verify with `sde version` and `sde doctor`.

## Contents

`Formula/sde.rb` is generated automatically. It is rendered from the template in
the [main repository](https://github.com/alexs60/safe-sde/blob/main/Formula/sde.rb)
by that repo's release workflow on every `v*.*.*` tag and committed here — do not
edit it by hand, as the next release will overwrite it.
