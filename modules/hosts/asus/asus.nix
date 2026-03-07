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
        greetd
        sway
        sysc-greet
      ]
      ++ [
        inputs.home-manager.nixosModules.home-manager
      ];
  };

  flake.nixosModules.asus = {pkgs, ...}: {
    nix.settings.experimental-features = ["nix-command" "flakes"];
    virtualisation.vmware.guest.enable = true;
    services.xserver.videoDrivers = ["vmware"];
    system.stateVersion = "25.11";
    # imports = [./_hardware-configuration.nix];
    home-manager.users.simeon = {pkgs, ...}: {
      home.username = "simeon";
      home.homeDirectory = "/home/simeon";
      home.stateVersion = "25.11";
      imports = with self.homeManager; [
        sway
      ];
    };

    nixpkgs.config.allowUnfree = true;

    boot.loader.grub.enable = true;
    boot.loader.grub.device = "<INSERT FS HERE>";
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
