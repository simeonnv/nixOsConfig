{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.asus = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with self.nixosModules;
      [
        asus
        sway
        greeter
        git
        fastfetch
        equibop
        stylix
      ]
      ++ [
        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.disko
        inputs.stylix.nixosModules.stylix
        ./_disko.nix
        (
          {pkgs, ...}: {
            nixpkgs.overlays = [
              inputs.nix-cachyos-kernel.overlays.default
            ];
          }
        )
      ];
  };

  flake.nixosModules.asus = {pkgs, ...}: {
    nix.settings.experimental-features = ["nix-command" "flakes"];
    hardware.graphics.enable = true;
    hardware.enableAllFirmware = true;

    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

    system.stateVersion = "25.11";
    # imports = [./_hardware-configuration.nix];
    services.xserver.videoDrivers = ["nvidia"];
    hardware.nvidia.open = false;
    home-manager.users.simeon = {pkgs, ...}: {
      home.username = "simeon";
      home.homeDirectory = "/home/simeon";
      home.stateVersion = "25.11";
      imports = with self.homeModules; [
        sway
        helix
        firefox
        fastfetch
        git
        yazi
        kitty
      ];
    };

    nixpkgs.config.allowUnfree = true;

    boot.loader.grub.enable = true;
    boot.loader.grub.device = "nodev";
    boot.loader.grub.efiSupport = true;
    # boot.loader.systemd-boot.enable = false;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot";

    networking.hostName = "asus";
    networking.networkmanager.enable = true;
    # networking.wireless.enable = true;

    time.timeZone = "Europe/Sofia";

    users.users.simeon = {
      isNormalUser = true;
      description = "simeon";
      extraGroups = ["networkmanager" "wheel"];
    };
  };
}
