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

---

The Serial (UART0) PinoutThe UART0 serial connection uses a 3.3V TTL logic level.
Do not connect a 5V power line to these data pins.
|"EXP" Header Pin Number | Pin Name / Function | Allwinner A64 SoC Pin | Connection to USB-to-UART Adapter|
|---|---|---|---|
|Pin 7|RX (Receive)PB9|Connect to TX on your adapter|
|Pin 8|TX (Transmit)PB8|Connect to RX on your adapter|
|Pin 6 (or Pin 9)|GND (Ground)GND|Connect to GND on your adapter|

---

Visual Orientation of the "EXP" HeaderThe EXP header is a 10-pin (2x5) male connector on the board.
The pin layout maps out as follows:text  (Edge of the Board / Audio Jack Side)
```
     [ Pin 2 ]  [ Pin 4 ]  [ Pin 6 ]  [ Pin 8 ]  [ Pin 10 ]
     [ Pin 1 ]  [ Pin 3 ]  [ Pin 5 ]  [ Pin 7 ]  [ Pin  9 ]
  (Inner Board Side / HDMI Side)
```
