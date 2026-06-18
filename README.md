# nixos-pine64
---

---
### check this flake
```
nix flake check -v -L --no-build --no-write-lock-file --all-systems github:denver-cfman/nixos-pine64?ref=main
```

### show this flake
```
nix flake show --all-systems --json github:denver-cfman/nixos-pine64?ref=main | jq '.'
```

### remote install via nixos-anywhere
```bash
nix run github:nix-community/nixos-anywhere -- --flake 'github:denver-cfman/nixos-pine64?ref=main#pine64' --target-host nixos@10.0.85.186
```

### remote update nix (nixos-rebuild) on cluster head
#### nixos-rebuild
```
sudo nixos-rebuild switch --impure --refresh --flake github:denver-cfman/nixos-pine64?ref=main#pine64 --no-write-lock-file
```
#### deploy-rs
```
K3S_TOKEN=thisisjustatest nix run github:serokell/deploy-rs github:denver-cfman/nixos-pine64?ref=main#pine64 -- -s -d --ssh-user giezac --hostname 10.0.81.99
```
#### build iso image for install
```
sudo nix build --impure --refresh --rebuild --no-update-lock-file -L -v github:denver-cfman/nixos-pine64?ref=main#nixosConfigurations.pine64.config.system.build.isoImage --extra-experimental-features "flakes nix-command"
```

#### Test Compile of a single package
```
nix build github:NixOS/nixpkgs/e4f449ab51a283676d3b520c3dbaa3eafa5025b4#pkgsCross.aarch64-multiplatform.screen
```
