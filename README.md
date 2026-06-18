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
### remote update nix (nixos-rebuild) on cluster head
#### nixos-rebuild
```
sudo nixos-rebuild switch --impure --refresh --flake github:denver-cfman/nixos-pine64?ref=main#pine64 --no-write-lock-file
```
#### build SD card image for install
```
nix build --impure --refresh --no-update-lock-file -L -v "github:denver-cfman/nixos-pine64?ref=main#default" --extra-experimental-features "flakes nix-command"
```

#### Test Compile of a single package
```
nix build github:NixOS/nixpkgs/e4f449ab51a283676d3b520c3dbaa3eafa5025b4#pkgsCross.aarch64-multiplatform.screen
```
