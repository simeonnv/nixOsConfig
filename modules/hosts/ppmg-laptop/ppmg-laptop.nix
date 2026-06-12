{
  inputs,
  self,
  ownerProfile,
  ...
}: {
  flake.nixosConfigurations.ppmg-laptop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with self.nixosModules;
      [
        ppmg-laptop
        git
        fastfetch
        zsh
        docker
        ssh
        screen
        sway
        greeter
        git
        fastfetch
        equibop
        stylix
        thunar
        zsh
        file-roller
        steam
        qimgv
        docker
        nh
        hacking
        qbittorrent
        manix
        libreoffice
        viber
        inkscape
        kitty
        dbeaver
        bluetooth
        sops
        telegram
        vlc
        rust
        signal
        vscode
        fonts
      ]
      ++ [
        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.disko
        inputs.stylix.nixosModules.stylix
        ./_disko.nix
      ];
  };

  flake.nixosModules.ppmg-laptop = {pkgs, ...}: {
    nix.settings.experimental-features = ["nix-command" "flakes"];
    hardware.enableAllFirmware = true;
    networking.firewall.enable = true;

    system.stateVersion = "25.11";
    home-manager.backupFileExtension = "backup";
    home-manager.users.${ownerProfile.name} = {pkgs, ...}: {
      home.username = ownerProfile.name;
      home.homeDirectory = "/home/${ownerProfile.name}";
      home.stateVersion = "25.11";
      imports = with self.homeModules; [
        helix
        fastfetch
        git
        yazi
        btop
        zsh
        eza
        zellij
        direnv
        sway
        firefox
        fastfetch
        kitty
      ];
    };

    nixpkgs.config.allowUnfree = true;
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "ppmg";
    networking.networkmanager.enable = true;

    programs.nix-ld.enable = true;

    time.timeZone = "Europe/Sofia";

    users.users.${ownerProfile.name} = {
      isNormalUser = true;
      description = ownerProfile.name;
      extraGroups = ["networkmanager" "wheel" "dialout" "adbusers"];
    };
  };
}
