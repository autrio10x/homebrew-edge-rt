# homebrew-edge-rt

Public Homebrew tap for **Autrio edge runtime** — formula **`keystone`**.

> Bare `brew install keystone` is Homebrew-core’s assembler. Always use the
> fully qualified name below.

## Install → configure → start

```bash
brew tap autrio10x/edge-rt
brew install autrio10x/edge-rt/keystone

# Edit identity only (package creates dirs + path defaults):
edit $(brew --prefix)/etc/keystone/keystone.toml

brew services start autrio10x/edge-rt/keystone
keystone --version
```

Requires **Apple Silicon (arm64)** and **Docker Desktop** running.

### What you edit

**File:** `$(brew --prefix)/etc/keystone/keystone.toml`  
(example also at `…/keystone.toml.example`)

```toml
autrio_url = "http://127.0.0.1:8002"
tenant_id = "00000000-0000-0000-0000-000000000000"
serial = "YOUR_DEVICE_SERIAL"
birth_secret = "YOUR_BIRTH_SECRET"
```

### What the package sets for you

| Knob | Value |
|------|--------|
| Supervisor | on |
| Vault | macOS Keychain |
| IPC / storage / creds | under `$(brew --prefix)/var/keystone/` |
| Config path | `KEYSTONE_CONFIG` → the toml above |
| Directories | created at install |

You do **not** create directories or set `KEYSTONE_IPC_PATH` / storage / creds.

## Stop / uninstall

```bash
brew services stop autrio10x/edge-rt/keystone
keystone-clean
brew uninstall autrio10x/edge-rt/keystone
```

## Logs

| | |
|--|--|
| stdout | `$(brew --prefix)/var/log/keystone.log` |
| stderr | `$(brew --prefix)/var/log/keystone.err.log` |

## Source

- App: https://github.com/autrio10x/keystone  
- Releases: https://github.com/autrio10x/homebrew-edge-rt/releases
