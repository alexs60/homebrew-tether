# homebrew-tether

Homebrew tap for [tether](https://github.com/alexs60/tether) — role-separated
container isolation for AI-assisted development on macOS.

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
