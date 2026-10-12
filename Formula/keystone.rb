# Reference formula — publish copies this to public tap autrio10x/homebrew-edge-rt.
#
# Consumers (fully qualified — bare `keystone` is Homebrew-core assembler):
#   brew tap autrio10x/edge-rt
#   brew install autrio10x/edge-rt/keystone
#   # edit /opt/homebrew/opt/keystone/sh.brew.keystone.plist
#   brew services start autrio10x/edge-rt/keystone
#
# Maintainer:
#   bump Cargo.toml version → make bottle-mac → ./deploy/scripts/publish-mac-bottle.sh
#
# --HEAD builds from the private app repo (eng-only; needs Rust + app access).

class Keystone < Formula
  desc "Keystone host authority daemon (Autrio edge runtime)"
  homepage "https://github.com/autrio10x/keystone"
  version "0.1.0"
  license "MIT"

  # Stable: Mach-O binary from the public edge-rt tap release (arm64 Darwin for now).
  url "https://github.com/autrio10x/homebrew-edge-rt/releases/download/keystone-v#{version}/keystone",
      using: :nounzip
  sha256 "a85cb003e96996224dedf75a96e8b939de8c23aefe25bdded4b0bfa31d59c3a5"

  head do
    url "https://github.com/autrio10x/keystone.git", branch: "develop"
    depends_on "rust" => :build
  end

  depends_on arch: :arm64

  service do
    run [opt_bin/"keystone"]
    environment_variables KEYSTONE_SUPERVISOR: "1",
                          KEYSTONE_KEYSTORE_BACKEND: "keychain"
    keep_alive true
    log_path var/"log/keystone.log"
    error_log_path var/"log/keystone.err.log"
    working_dir var/"keystone"
  end

  def install
    if build.head?
      system "cargo", "install", "--locked", "--root", prefix, "--path", "crates/bin"
      if (buildpath/"deploy/mac/keystone-clean.sh").exist?
        bin.install "deploy/mac/keystone-clean.sh" => "keystone-clean"
      end
    else
      chmod "+x", "keystone"
      bin.install "keystone"
    end
    # Tap-shipped wipe helper (stable path; also fills HEAD if repo copy missing).
    helper = tap.path/"keystone-clean"
    if helper.exist? && !(bin/"keystone-clean").exist?
      bin.install helper
    end
    (var/"keystone").mkpath
    (var/"log").mkpath
  end

  def caveats
    <<~EOS
      Configure identity in the brew service plist (same knobs as lab env):

        /opt/homebrew/opt/keystone/sh.brew.keystone.plist

      EnvironmentVariables (edit in place):
        KEYSTONE_SUPERVISOR, KEYSTONE_KEYSTORE_BACKEND=keychain
        KEYSTONE_AUTRIO_URL, KEYSTONE_TENANT_ID, KEYSTONE_SERIAL
        KEYSTONE_BIRTH_SECRET
        optional: KEYSTONE_IPC_PATH, KEYSTONE_STORAGE_ROOT, KEYSTONE_CREDENTIAL_DIR

      Then:
        brew services start autrio10x/edge-rt/keystone
        keystone --version

      Uninstall (wipe Keychain, then remove package):
        brew services stop autrio10x/edge-rt/keystone
        keystone-clean
        brew uninstall autrio10x/edge-rt/keystone

      See deploy/mac/README.md in the app repo.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/keystone --version")
  end
end
