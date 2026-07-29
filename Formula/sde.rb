# Homebrew formula for sde.
#
# This file is the canonical template that ships in the main repository.
# The release workflow (.github/workflows/release.yml) substitutes the
# 0.0.1, 04036225fa659a97cd3ba12a0c5e5d750d17da358027df7350859d5720bc08d8, f957d8ee8c80a29d39cb70b5f04047ea2121e96e296280ed27661b938a7a82ac, and alexs60/safe-sde placeholders at
# release time and commits the rendered copy into the homebrew-sde tap repo.
#
# alexs60/safe-sde is the full "owner/repo" slug of the source repository (from
# ${{ github.repository }}), not just the owner — the repository is not
# necessarily named "sde", so the release-asset URLs cannot assume it is.
#
# To install from the tap (once a release has been published):
#
#   brew tap alexs60/sde
#   brew install sde

class Sde < Formula
  desc "Role-separated container isolation for AI-assisted development"
  homepage "https://github.com/alexs60/safe-sde"
  license "MIT"

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
    url "https://github.com/alexs60/safe-sde/releases/download/v0.0.1/sde-darwin-arm64.tar.gz"
    sha256 "04036225fa659a97cd3ba12a0c5e5d750d17da358027df7350859d5720bc08d8"
  else
    # amd64 (Intel Mac)
    url "https://github.com/alexs60/safe-sde/releases/download/v0.0.1/sde-darwin-amd64.tar.gz"
    sha256 "f957d8ee8c80a29d39cb70b5f04047ea2121e96e296280ed27661b938a7a82ac"
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
