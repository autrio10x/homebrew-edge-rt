# homebrew-edge-rt

Public Homebrew tap for **Autrio edge runtime** — formula **keystone**.

```bash
brew tap autrio10x/edge-rt
brew install autrio10x/edge-rt/keystone
# edit /opt/homebrew/opt/keystone/sh.brew.keystone.plist
brew services start autrio10x/edge-rt/keystone
```

Uninstall (wipe Keychain first):

```bash
brew services stop autrio10x/edge-rt/keystone
keystone-clean
brew uninstall autrio10x/edge-rt/keystone
```

Bare `brew install keystone` is Homebrew-core’s assembler — always use the fully
qualified formula name.
