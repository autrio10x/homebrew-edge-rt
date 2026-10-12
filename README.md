# homebrew-edge-rt

Public Homebrew tap for **Autrio edge runtime** — formula **`keystone`**
(host authority daemon).

> **Do not** run bare `brew install keystone` — that installs Homebrew-core’s
> Keystone Engine assembler. Always use the fully qualified name below.

## Install

```bash
brew tap autrio10x/edge-rt
brew install autrio10x/edge-rt/keystone
```

Requires **Apple Silicon (arm64)**. Stable install downloads a published binary
(no Rust toolchain needed).

## Configure — edit the brew plist

After install, brew generates a LaunchAgent plist. **This is where you set
identity** (same env vars the daemon reads in lab):

| | |
|--|--|
| **Path** | `/opt/homebrew/opt/keystone/sh.brew.keystone.plist` |
| **Edit** | Open in a text editor; change the `EnvironmentVariables` dict |
| **Apply** | Save, then `brew services restart autrio10x/edge-rt/keystone` |

### Keys

| Key | Required | Meaning |
|-----|----------|---------|
| `KEYSTONE_SUPERVISOR` | yes | Set to `1` (shipped default) |
| `KEYSTONE_KEYSTORE_BACKEND` | yes | `keychain` on Mac (shipped default; daemon fails if Keychain unavailable) |
| `KEYSTONE_AUTRIO_URL` | yes | Autrio base URL (dev / stage / prod) |
| `KEYSTONE_TENANT_ID` | yes | Tenant UUID |
| `KEYSTONE_SERIAL` | yes | Device serial |
| `KEYSTONE_BIRTH_SECRET` | yes* | Birth join secret — seeded into Keychain if empty (*ignored if birth slot already occupied) |
| `KEYSTONE_IPC_PATH` | no | Unix socket path for local IPC |
| `KEYSTONE_STORAGE_ROOT` | no | On-disk storage root |
| `KEYSTONE_CREDENTIAL_DIR` | no | Credential directory (file-backend labs) |

### Example `EnvironmentVariables` block

Replace the shipped defaults so the dict looks like:

```xml
<key>EnvironmentVariables</key>
<dict>
        <key>KEYSTONE_SUPERVISOR</key>
        <string>1</string>
        <key>KEYSTONE_KEYSTORE_BACKEND</key>
        <string>keychain</string>
        <key>KEYSTONE_AUTRIO_URL</key>
        <string>https://autrio.example.example</string>
        <key>KEYSTONE_TENANT_ID</key>
        <string>00000000-0000-0000-0000-000000000000</string>
        <key>KEYSTONE_SERIAL</key>
        <string>YOUR_DEVICE_SERIAL</string>
        <key>KEYSTONE_BIRTH_SECRET</key>
        <string>YOUR_BIRTH_SECRET</string>
</dict>
```

`brew upgrade` / reinstall may regenerate the plist — re-apply these values
after an upgrade.

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

Working directory: `/opt/homebrew/var/keystone`

## Uninstall

`brew uninstall` removes the package only. Secrets in macOS Keychain
(`com.autrio.keystone`) remain unless wiped:

```bash
brew services stop autrio10x/edge-rt/keystone
keystone-clean          # wipe Keychain slots
brew uninstall autrio10x/edge-rt/keystone
```

## Troubleshooting

| Symptom | Check |
|---------|--------|
| Wrong binary / assembler | `which keystone` and `keystone --version` — expect Autrio Keystone version, not `kstool` |
| Service won’t stay up | stderr log; Keychain prompt; plist `KEYSTONE_*` values |
| Identity wrong after upgrade | Re-edit `/opt/homebrew/opt/keystone/sh.brew.keystone.plist` |

## Source / maintainers

- App source: https://github.com/autrio10x/keystone  
- Release binaries: [Releases](https://github.com/autrio10x/homebrew-edge-rt/releases)
