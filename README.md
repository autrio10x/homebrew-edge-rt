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
keystone status
```

Requires **Apple Silicon (arm64)** and **Docker Desktop** running.

### Status (no log diving)

```bash
keystone status
```

Prints `running`, config path, Autrio URL / tenant / serial, IPC socket state,
and the brew err log path. Does **not** print secrets. Exit `0` if the Runtime
API socket accepts connections.

### What you edit

**File:** `$(brew --prefix)/etc/keystone/keystone.toml`  
(example also at `…/keystone.toml.example`)

```toml
autrio_url = "http://127.0.0.1:8002"
tenant_key = "helios_edge"
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

## Stop / uninstall (fully clean)

Homebrew **keeps** `etc/` on uninstall by design. Run `keystone-clean` **before**
uninstall — it wipes Keychain, `etc/keystone`, `var/keystone`, and logs:

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
