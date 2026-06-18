{
  description = "NixOS SD Card Image for Pine64+ (Allwinner A64)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      # Use nixpkgs local architecture discovery to allow native AND cross evaluation
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      
      # Helper function to generate pkgs per-architecture
      makePkgs = currentSystem: import nixpkgs {
        system = currentSystem;
        # DYNAMIC TRIGGER: Only spin up the cross toolchain if we are compiling
        # on an x86_64 machine targeting an aarch64 machine.
        crossSystem = if currentSystem == "x86_64-linux" then {
          config = "aarch64-linux";
        } else null;
        
        config = {
          allowUnfree = true;
        };
      };
    in {
      # Fallback to standard build target mapping on x86 host
      packages.x86_64-linux.default = self.nixosConfigurations.pine64.config.system.build.sdImage;
      packages.aarch64-linux.default = self.nixosConfigurations.pine64.config.system.build.sdImage;

      nixosConfigurations.pine64 = nixpkgs.lib.nixosSystem {
        # This safely pulls down the evaluation architecture context 
        # based on the host calling it.
        modules = [
          # Bind the correct pkgs toolchain array dynamically
          ({ ... }: {
            nixpkgs.pkgs = makePkgs builtins.currentSystem;
          })

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

            boot.tmp.useTmpfs = true;
            boot.tmp.tmpfsSize = "256M"; # Cap it so it doesn't exhaust your RAM
            
            fileSystems."/var/log" = {
              device = "none";
              fsType = "tmpfs";
              options = [ "mode=0755" "strictatime" "size=64M" ];
            };

            time.timeZone = "America/Denver";
          
            i18n.defaultLocale = "en_US.UTF-8";
          
            i18n.extraLocaleSettings = {
              LC_ADDRESS = "en_US.UTF-8";
              LC_IDENTIFICATION = "en_US.UTF-8";
              LC_MEASUREMENT = "en_US.UTF-8";
              LC_MONETARY = "en_US.UTF-8";
              LC_NAME = "en_US.UTF-8";
              LC_NUMERIC = "en_US.UTF-8";
              LC_PAPER = "en_US.UTF-8";
              LC_TELEPHONE = "en_US.UTF-8";
              LC_TIME = "en_US.UTF-8";
            };

            users.users.giezac = {
              isNormalUser = true;
              description = "giezac";
              extraGroups = [ "networkmanager" "wheel" ];
              packages = with pkgs; [
                oh-my-zsh
              ];
              password = "changeme";
              openssh.authorizedKeys.keys = [
                  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCZawwmpdesq0ZvtXTdPekpjK3OYiPONrKO0no625FqYG8A8fZY++cxjG4my6HgmoaBrZiWvRJTa0WfTfw9Tzx9xt/FKrCB4bk9G33WP+RJNF7AEo3wkGGBLHzxp9bnhzzxdJOQCV67DRDxQNjMiR5S/bkSU+QYPDq+MLLx8mFz8lfzOSThVgDLjOj7lsRAJcrFDawsjZYHjsVBdDfCkjXGPKT7/c90k0BOvOjnOZ4vEn1w2s/Neq0rDTJYDUSmu9SzW/+WkM1rZa4GS5QGFMJVrI1Ow3X8tiUYpAp1oa0MyIpRkpuP39W+I6qaRBW4/+lyJYWsLP09hU7K2wT6OGap forGitHub"
              ];
            };
          
            users.users.root.openssh.authorizedKeys.keys = [
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPmNXnRi9A/6hQL0wxpyti2Qo+Sd8LZt0uLu/hSJ91tH root@R210ii"
            ];
            networking.hostName = "pine64";

            systemd.services."serial-getty@ttyS0".enable = true;
          
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
          
            environment.systemPackages = with pkgs; [
              vim
              wget
              htop
              btop
              iftop
              curl
              git
              fastfetch
              jq
              screen
            ];

            services.openssh = {
              enable = true;
              settings.PermitRootLogin = "yes";
            };
            services.getty.autologinUser = "giezac";

            sdImage = {
              imageName = "pine64-plus-sd-image.img";
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
