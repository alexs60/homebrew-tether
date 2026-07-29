# Homebrew formula for sde.
#
# This file is the canonical template that ships in the main repository.
# The release workflow (.github/workflows/release.yml) substitutes the
# 0.0.2, d03f0f71d01b9e0e01c83fabe3d894a888d4000b3d03ee49877ba9c19b229fb3, 3e6b1e226e0176f6087eff35cf708e98ba292be5f1502b4d53441ffb754098f8, and alexs60/safe-sde placeholders at
# release time and commits the rendered copy into the homebrew-sde tap repo.
#
# alexs60/safe-sde is the full "owner/repo" slug of the source repository (from
# ${{ github.repository }}), not just the owner — the repository is not
# necessarily named "sde", so the release-asset URLs cannot assume it is.
#
# To install from the tap (once a release has been published):
#
#   brew tap alexs60/sde
#   brew trust alexs60/sde   # required: Homebrew blocks untrusted third-party taps
#   brew install sde

class Sde < Formula
  desc "Role-separated container isolation for AI-assisted development"
  homepage "https://github.com/alexs60/safe-sde"
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
    url "https://github.com/alexs60/safe-sde/releases/download/v0.0.2/sde-darwin-arm64.tar.gz"
    sha256 "d03f0f71d01b9e0e01c83fabe3d894a888d4000b3d03ee49877ba9c19b229fb3"
  else
    # amd64 (Intel Mac)
    url "https://github.com/alexs60/safe-sde/releases/download/v0.0.2/sde-darwin-amd64.tar.gz"
    sha256 "3e6b1e226e0176f6087eff35cf708e98ba292be5f1502b4d53441ffb754098f8"
  end

  # macOS only — the sde binary is a darwin mach-o executable.
  depends_on :macos

  def install
    # Install the host binary into the Homebrew prefix bin directory so it is
    # available on PATH after `brew install`.
    bin.install "sde"

    # Stash both Linux credential-helper binaries under libexec (inside the
    # Cellar prefix).  They are Linux ELF binaries, not executable on macOS;
    # sde bind-mounts the appropriate one into Linux containers at runtime.
    #
    # These deliberately stay inside the Cellar rather than being copied to
    # ~/.sde/bin: Homebrew's post_install runs under a sandbox that denies
    # writes to $HOME, so seeding the user's home directory from a formula is
    # not possible.  sde resolves the helpers relative to its own executable
    # (../libexec) — see HelperBinaryPath in cmd/sde/deps.go.
    libexec.install "sde-credential-helper-linux-arm64",
                    "sde-credential-helper-linux-amd64"

    # sde is GPL-3.0-or-later, so the licence text travels with the binary.
    # `pkgshare` rather than `prefix` because Homebrew's `brew style` prefers
    # documentation under share/<name>; the tarball carries both files (see
    # the packaging steps in .github/workflows/release.yml).
    pkgshare.install "LICENSE", "COPYRIGHT"
  end

  def caveats
    <<~EOS
      Linux credential-helper binaries are installed in:
        #{libexec}

      sde will bind-mount the appropriate binary into each container
      automatically — no manual configuration is required.

      To get started:
        sde doctor    # verify dependencies (Docker/OrbStack, etc.)
        sde init      # detect your project stack and write topology.yaml
        sde up        # provision and start containers
        sde shell     # open a shell in the development container

      For credential management:
        sde auth github --store   # store a GitHub PAT in the macOS keychain
    EOS
  end

  test do
    assert_match "sde #{version}", shell_output("#{bin}/sde version")
  end
end
