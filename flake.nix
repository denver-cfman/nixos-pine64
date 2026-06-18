{
  description = "NixOS SD Card Image for Pine64+ (Allwinner A64)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      hostSystem = "x86_64-linux";
      targetSystem = "aarch64-linux";
      
      pkgs = import nixpkgs {
        system = hostSystem;
        crossSystem = {
          config = targetSystem;
        };
      };
    in {
      # 1. FIX: Keeps the flake packages buildable via standard 'nix build'
      packages.${hostSystem}.default = self.nixosConfigurations.pine64.config.system.build.sdImage;

      # 2. FIX: Exposes the exact named configuration 'nixos-rebuild' expects to find
      nixosConfigurations.pine64 = nixpkgs.lib.nixosSystem {
        inherit pkgs;
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"

          ({ config, pkgs, ... }: {
            boot.kernelPackages = pkgs.linuxPackages_latest;
            
            boot.supportedFilesystems = nixpkgs.lib.mkForce [ "vfat" "ext4" "f2fs" ];

            boot.initrd.availableKernelModules = [
              "sunxi-mmc"
              "uio_pdrv_genirq"
              "usb_storage"
            ];

            boot.kernelParams = [
              "console=ttyS0,115200n8"
              "console=tty1"
              "earlycon=uart8250,mmio32,0x01c28000"
              "panic=10"
            ];

            networking.hostName = "pine64";
            services.openssh = {
              enable = true;
              settings.PermitRootLogin = "yes";
            };
            services.getty.autologinUser = "root";

            # Configure the SD card image construction settings
            image.fileName = "pine64-plus-sd-image.img";
            sdImage = {
              # FIX: Restored required parameter inside the correct configuration block
              #imageName = "pine64-plus-sd-image.img"; 
              
              postBuildCommands = '' 
                echo "==> Embedding Allwinner SPL/U-Boot into raw image..." 
                dd if=${pkgs.ubootPine64}/u-boot-sunxi-with-spl.bin of=$img conv=notrunc bs=1k seek=8 
              '';
            };

            system.stateVersion = "26.05";
          })
        ];
      };
    };
}
