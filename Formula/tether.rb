# Homebrew formula for tether.
#
# This file is the canonical template that ships in the main repository.
# The release workflow (.github/workflows/release.yml) substitutes the
# 0.1.0, 391e2312f32d51e78f5dbb63c339c023f925e63fc61dce34e1044b253402ea61, 39f07ee9cac8c91c63712a23d5a7eba81489dc340291021bb8fd373ea87bf17b, and alexs60/tether placeholders at
# release time and commits the rendered copy into the homebrew-tether tap repo.
#
# alexs60/tether is the full "owner/repo" slug of the source repository (from
# ${{ github.repository }}), not just the owner — the repository is not
# necessarily named "tether", so the release-asset URLs cannot assume it is.
#
# To install from the tap (once a release has been published):
#
#   brew tap alexs60/tether
#   brew trust alexs60/tether   # required: Homebrew blocks untrusted third-party taps
#   brew install tether

class Tether < Formula
  desc "Role-separated container isolation for AI-assisted development"
  homepage "https://github.com/alexs60/tether"
  license "GPL-3.0-or-later"

  # Architecture-specific release tarballs.
  #
  # `on_arm`/`on_intel` blocks may NOT contain `url`/`sha256` (brew audit
  # rejects it), so select on Hardware::CPU at formula-eval time instead —
  # this is the supported pattern for arch-specific binary downloads.
  #
  # No `version` stanza: brew audit flags it as redundant because the version is
  # scanned out of the ".../download/vX.Y.Z/..." URL path.
  if Hardware::CPU.arm?
    # arm64 (Apple Silicon)
    url "https://github.com/alexs60/tether/releases/download/v0.1.0/tether-darwin-arm64.tar.gz"
    sha256 "391e2312f32d51e78f5dbb63c339c023f925e63fc61dce34e1044b253402ea61"
  else
    # amd64 (Intel Mac)
    url "https://github.com/alexs60/tether/releases/download/v0.1.0/tether-darwin-amd64.tar.gz"
    sha256 "39f07ee9cac8c91c63712a23d5a7eba81489dc340291021bb8fd373ea87bf17b"
  end

  # macOS only — the tether binary is a darwin mach-o executable.
  depends_on :macos

  def install
    # Install the host binary into the Homebrew prefix bin directory so it is
    # available on PATH after `brew install`.
    bin.install "tether"

    # Stash both Linux credential-helper binaries under libexec (inside the
    # Cellar prefix).  They are Linux ELF binaries, not executable on macOS;
    # tether bind-mounts the appropriate one into Linux containers at runtime.
    #
    # These deliberately stay inside the Cellar rather than being copied to
    # ~/.tether/bin: Homebrew's post_install runs under a sandbox that denies
    # writes to $HOME, so seeding the user's home directory from a formula is
    # not possible.  tether resolves the helpers relative to its own executable
    # (../libexec) — see HelperBinaryPath in cmd/tether/deps.go.
    libexec.install "tether-credential-helper-linux-arm64",
                    "tether-credential-helper-linux-amd64"

    # tether is GPL-3.0-or-later, so the licence text travels with the binary.
    # `pkgshare` rather than `prefix` because Homebrew's `brew style` prefers
    # documentation under share/<name>; the tarball carries both files (see
    # the packaging steps in .github/workflows/release.yml).
    pkgshare.install "LICENSE", "COPYRIGHT"
  end

  def caveats
    <<~EOS
      Linux credential-helper binaries are installed in:
        #{libexec}

      tether will bind-mount the appropriate binary into each container
      automatically — no manual configuration is required.

      To get started:
        tether doctor    # verify dependencies (Docker/OrbStack, etc.)
        tether init      # detect your project stack and write topology.yaml
        tether up        # provision and start containers
        tether shell     # open a shell in the development container

      For credential management:
        tether auth github --store   # store a GitHub PAT in the macOS keychain
    EOS
  end

  test do
    assert_match "tether #{version}", shell_output("#{bin}/tether version")
  end
end
