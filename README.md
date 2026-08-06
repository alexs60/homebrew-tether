# homebrew-tether

Homebrew tap for [tether](https://github.com/alexs60/tether) — role-separated
container isolation for AI-assisted development on macOS.

> **This tap has no formula yet.** `Formula/tether.rb` is published by the
> v0.1.0 release, which has not been tagged. The commands below will not work
> until then.

## Install

```sh
brew tap alexs60/tether
brew install tether
```

Then verify with `tether version` and `tether doctor`.

### Upgrading from `sde`

tether was called `sde` up to v0.0.3. This tap is the same repository under a new
name, so drop the old tap before adding the new one:

```sh
brew uninstall sde
brew untap alexs60/sde
brew tap alexs60/tether
brew install tether
```

The old `Formula/sde.rb` has been removed. It was already unusable: its download
URLs point at release assets in a repository that is not public, so
`brew install sde` returned 404 regardless.

The rename is a hard break: state moves from `~/.sde/` to `~/.tether/` and
nothing migrates automatically. Run `sde nuke` with the *old* binary before
uninstalling it. See the
[changelog](https://github.com/alexs60/tether/blob/main/CHANGELOG.md) for the
full list of what changed.

## Contents

`Formula/tether.rb` is generated automatically. It is rendered from the template
in the [main repository](https://github.com/alexs60/tether/blob/main/Formula/tether.rb)
by that repo's release workflow on every `v*.*.*` tag and committed here — do not
edit it by hand, as the next release will overwrite it.
