# Reference formula — publish copies this to public tap autrio10x/homebrew-edge-rt,
# then stamps version + sha256 on the **tap** only (never mutates this file).
#
# Consumers:
#   brew tap autrio10x/edge-rt
#   brew install autrio10x/edge-rt/keystone
#   edit $(brew --prefix)/etc/keystone/keystone.toml   # identity only
#   brew services start autrio10x/edge-rt/keystone
#
# Maintainer: make bottle-mac && ./deploy/scripts/publish-mac-bottle.sh
# Live bottle sha lives on the tap / GitHub Release — not in this template.

class Keystone < Formula
  desc "Keystone host authority daemon (Autrio edge runtime)"
  homepage "https://github.com/autrio10x/keystone"
  version "0.1.0"
  license "MIT"

  url "https://github.com/autrio10x/homebrew-edge-rt/releases/download/keystone-v#{version}/keystone",
      using: :nounzip
  # Placeholder — publish-mac-bottle.sh overwrites this on the tap clone only.
  sha256 "c06650540ad2f44a98bb0e3fb4298eaddf9af303aafdaf108e0bb4900f7c415c"

  head do
    url "https://github.com/autrio10x/keystone.git", branch: "develop"
    depends_on "rust" => :build
  end

  depends_on arch: :arm64

  service do
    run [opt_bin/"keystone"]
    environment_variables KEYSTONE_SUPERVISOR: "1",
                          KEYSTONE_KEYSTORE_BACKEND: "keychain",
                          KEYSTONE_CONFIG: etc/"keystone/keystone.toml",
                          KEYSTONE_IPC_PATH: var/"keystone/runtime.sock",
                          KEYSTONE_STORAGE_ROOT: var/"keystone/storage",
                          KEYSTONE_CREDENTIAL_DIR: var/"keystone/creds",
                          PATH: "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/Applications/Docker.app/Contents/Resources/bin"
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

    unless (bin/"keystone-clean").exist?
      helper = tap.path/"keystone-clean"
      if helper.exist?
        bin.mkpath
        FileUtils.cp helper, bin/"keystone-clean"
        chmod 0755, bin/"keystone-clean"
      end
    end

    # Package layout — no operator mkdir.
    (var/"keystone").mkpath
    (var/"keystone/storage").mkpath
    (var/"keystone/creds").mkpath
    (var/"log").mkpath
    (etc/"keystone").mkpath

    conf = etc/"keystone/keystone.toml"
    example = etc/"keystone/keystone.toml.example"
    example_body = <<~EOS
      # Keystone identity (edit this file — paths are set by the brew service).
      # Then: brew services start autrio10x/edge-rt/keystone

      autrio_url = "http://127.0.0.1:8002"
      tenant_key = "helios_edge"
      serial = "CHANGE_ME_SERIAL"
      birth_secret = "CHANGE_ME_BIRTH_SECRET"
    EOS
    # Never overwrite etc/ on upgrade/reinstall (Homebrew refuses overwrite).
    example.write example_body unless example.exist?
    conf.write example_body unless conf.exist?
  end

  def caveats
    <<~EOS
      Edit identity (only):

        #{etc}/keystone/keystone.toml

      Then:

        brew services start autrio10x/edge-rt/keystone
        keystone status

      Paths, supervisor, and keychain are package defaults.
      Docker Desktop must be running (Pilot OCI).

      Logs: #{var}/log/keystone.log
           #{var}/log/keystone.err.log

      Uninstall (keystone-clean removes etc/var — brew will not):
        brew services stop autrio10x/edge-rt/keystone
        keystone-clean
        brew uninstall autrio10x/edge-rt/keystone
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/keystone --version")
  end
end
