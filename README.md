# homebrew-edge-rt

Public Homebrew tap for **Autrio edge runtime** — formula **`keystone`**
(host authority daemon).

> **Do not** run bare `brew install keystone` — that installs Homebrew-core’s
> Keystone Engine assembler. Always use the fully qualified name below.

## Install

```bash
brew tap autrio10x/edge-rt
brew install autrio10x/edge-rt/keystone
mkdir -p /opt/homebrew/var/keystone/storage /opt/homebrew/var/keystone/creds
```

Requires **Apple Silicon (arm64)**. Stable install downloads a published binary
(no Rust toolchain needed).

## Configure — `~/.homebrew/services/keystone.env`

`brew services start` **regenerates** `~/Library/LaunchAgents/sh.brew.keystone.plist`
from the formula on every start/restart. Do **not** rely on editing that plist for
identity — your edits are wiped.

Use Homebrew’s supported env override file instead (persists across upgrades):

**Path:** `~/.homebrew/services/keystone.env`

```bash
mkdir -p ~/.homebrew/services
cat > ~/.homebrew/services/keystone.env <<'EOF'
KEYSTONE_AUTRIO_URL=https://autrio.example.example
KEYSTONE_TENANT_ID=00000000-0000-0000-0000-000000000000
KEYSTONE_SERIAL=YOUR_DEVICE_SERIAL
KEYSTONE_BIRTH_SECRET=YOUR_BIRTH_SECRET
KEYSTONE_IPC_PATH=/opt/homebrew/var/keystone/runtime.sock
KEYSTONE_STORAGE_ROOT=/opt/homebrew/var/keystone/storage
KEYSTONE_CREDENTIAL_DIR=/opt/homebrew/var/keystone/creds
EOF

brew services restart autrio10x/edge-rt/keystone
```

### Required keys

| Key | Meaning |
|-----|---------|
| `KEYSTONE_AUTRIO_URL` | Autrio base URL |
| `KEYSTONE_TENANT_ID` | Tenant UUID |
| `KEYSTONE_SERIAL` | Device serial |
| `KEYSTONE_BIRTH_SECRET` | Birth join secret (seed-if-empty into Keychain) |
| `KEYSTONE_IPC_PATH` | e.g. `/opt/homebrew/var/keystone/runtime.sock` |
| `KEYSTONE_STORAGE_ROOT` | e.g. `/opt/homebrew/var/keystone/storage` |
| `KEYSTONE_CREDENTIAL_DIR` | e.g. `/opt/homebrew/var/keystone/creds` |

Package defaults already set by the formula service: `KEYSTONE_SUPERVISOR=1`,
`KEYSTONE_KEYSTORE_BACKEND=keychain`.

Example file in this repo: [`keystone.env.example`](keystone.env.example).

Optional full plist template (reference only): [`keystone.plist.example`](keystone.plist.example).

## Start / stop

```bash
brew services start autrio10x/edge-rt/keystone
keystone --version

brew services stop autrio10x/edge-rt/keystone
brew services restart autrio10x/edge-rt/keystone
```

### Logs

| Stream | Path |
|--------|------|
| stdout | `/opt/homebrew/var/log/keystone.log` |
| stderr | `/opt/homebrew/var/log/keystone.err.log` |

## Uninstall

```bash
brew services stop autrio10x/edge-rt/keystone
keystone-clean
brew uninstall autrio10x/edge-rt/keystone
# optional: rm ~/.homebrew/services/keystone.env
```

## Troubleshooting

| Symptom | Check |
|---------|--------|
| `missing_ipc_path` | Add paths to `~/.homebrew/services/keystone.env`, then `brew services restart` |
| Edits to LaunchAgents ignored | Expected — use `keystone.env`, not the plist |
| Wrong binary | `keystone --version` must show Autrio Keystone, not Homebrew-core assembler |

## Source / maintainers

- App source: https://github.com/autrio10x/keystone  
- Release binaries: [Releases](https://github.com/autrio10x/homebrew-edge-rt/releases)
