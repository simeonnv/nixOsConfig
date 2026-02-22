{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.asus = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with self.nixosModules; [
      asus
    ];
  };

  flake.nixosModules.asus = {pkgs, ...}: {
    system.stateVersion = "25.05";
    imports = [./_hardware-configuration.nix];
    nixpkgs.config.allowUnfree = true;

    boot.loader.grub.enable = true;
    boot.loader.grub.device = "nodev";
    boot.loader.grub.efiSupport = true;
    boot.loader.systemd-boot.enable = false;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "asus";
    networking.networkmanager.enable = true;
    time.timeZone = "Europe/Sofia";

    environment.systemPackages = with pkgs; [firefox git helix kitty];
    users.users.simeon = {
      isNormalUser = true;
      description = "simeon";
      extraGroups = ["networkmanager" "wheel"];
    };

    programs.firefox.enable = true;
  };
}
