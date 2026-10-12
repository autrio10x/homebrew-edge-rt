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

## Configure — edit the brew plist

After the first `brew services start`, launchd uses a **copy** under LaunchAgents.
Edit that live file (or edit the template and copy it over).

| | |
|--|--|
| **Live (what runs)** | `~/Library/LaunchAgents/sh.brew.keystone.plist` |
| **Template (Cellar)** | `/opt/homebrew/opt/keystone/sh.brew.keystone.plist` |

```bash
# after editing the template:
cp /opt/homebrew/opt/keystone/sh.brew.keystone.plist ~/Library/LaunchAgents/sh.brew.keystone.plist
brew services restart autrio10x/edge-rt/keystone
```

### Required `KEYSTONE_*` keys

| Key | Meaning |
|-----|---------|
| `KEYSTONE_SUPERVISOR` | `1` |
| `KEYSTONE_KEYSTORE_BACKEND` | `keychain` |
| `KEYSTONE_AUTRIO_URL` | Autrio base URL |
| `KEYSTONE_TENANT_ID` | Tenant UUID |
| `KEYSTONE_SERIAL` | Device serial |
| `KEYSTONE_BIRTH_SECRET` | Birth join secret (seed-if-empty into Keychain) |
| `KEYSTONE_IPC_PATH` | e.g. `/opt/homebrew/var/keystone/runtime.sock` |
| `KEYSTONE_STORAGE_ROOT` | e.g. `/opt/homebrew/var/keystone/storage` |
| `KEYSTONE_CREDENTIAL_DIR` | e.g. `/opt/homebrew/var/keystone/creds` |

### Full example plist

Copy this into `~/Library/LaunchAgents/sh.brew.keystone.plist` (replace
`YOUR_*` / example URL / tenant). Keep `Label` and paths as shown for a
Homebrew prefix install:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
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
		<key>KEYSTONE_IPC_PATH</key>
		<string>/opt/homebrew/var/keystone/runtime.sock</string>
		<key>KEYSTONE_STORAGE_ROOT</key>
		<string>/opt/homebrew/var/keystone/storage</string>
		<key>KEYSTONE_CREDENTIAL_DIR</key>
		<string>/opt/homebrew/var/keystone/creds</string>
	</dict>
	<key>KeepAlive</key>
	<true/>
	<key>Label</key>
	<string>sh.brew.keystone</string>
	<key>LimitLoadToSessionType</key>
	<array>
		<string>Aqua</string>
		<string>Background</string>
		<string>LoginWindow</string>
		<string>StandardIO</string>
		<string>System</string>
	</array>
	<key>ProgramArguments</key>
	<array>
		<string>/opt/homebrew/opt/keystone/bin/keystone</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>StandardErrorPath</key>
	<string>/opt/homebrew/var/log/keystone.err.log</string>
	<key>StandardOutPath</key>
	<string>/opt/homebrew/var/log/keystone.log</string>
	<key>WorkingDirectory</key>
	<string>/opt/homebrew/var/keystone</string>
</dict>
</plist>
```

`brew upgrade` / reinstall may reset the Cellar template — re-copy into
LaunchAgents after upgrading.

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
```

## Troubleshooting

| Symptom | Check |
|---------|--------|
| `missing_ipc_path` | Set `KEYSTONE_IPC_PATH` / `STORAGE_ROOT` / `CREDENTIAL_DIR` in the **LaunchAgents** plist |
| Edits ignored | You edited Cellar only — copy to `~/Library/LaunchAgents/sh.brew.keystone.plist` then restart |
| Wrong binary | `keystone --version` must show Autrio Keystone, not Homebrew-core assembler |

## Source / maintainers

- App source: https://github.com/autrio10x/keystone  
- Release binaries: [Releases](https://github.com/autrio10x/homebrew-edge-rt/releases)
