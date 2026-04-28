{
  inputs,
  self,
  ownerProfile,
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
        thunar
        zsh
        file-roller
        steam
        qimgv
        docker
        nvidia
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
        i2pd
        vscode
        minecraft
        fonts
      ]
      ++ [
        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.disko
        inputs.stylix.nixosModules.stylix
        ./_disko.nix
        (
          {pkgs, ...}: {
            nixpkgs.overlays = [
              inputs.nix-cachyos-kernel.overlays.pinned
            ];
          }
        )
      ];
  };

  flake.nixosModules.asus = {pkgs, ...}: {
    nix.settings.experimental-features = ["nix-command" "flakes"];
    hardware.enableAllFirmware = true;
    nixpkgs.config.allowUnfree = true;

    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
    boot.kernelParams = ["pcie_aspm=off"];

    system.stateVersion = "25.11";
    # imports = [./_hardware-configuration.nix];
    home-manager.backupFileExtension = "backup";
    home-manager.users.${ownerProfile.name} = {pkgs, ...}: {
      home.username = ownerProfile.name;
      home.homeDirectory = "/home/${ownerProfile.name}";
      home.stateVersion = "25.11";
      imports = with self.homeModules; [
        sway
        helix
        firefox
        fastfetch
        git
        yazi
        btop
        kitty
        zsh
        eza
        zellij
        direnv
      ];
    };

    boot.loader.grub.enable = true;
    boot.loader.grub.device = "nodev";
    boot.loader.grub.efiSupport = true;
    # boot.loader.systemd-boot.enable = false;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot";

    programs.nix-ld.enable = true;
    networking.hostName = "asus";
    networking.networkmanager.enable = true;
    networking.networkmanager.wifi.powersave = false;
    networking.interfaces."eno1".mtu = 1400;
    networking.interfaces."wlp3s0".mtu = 1400;
    boot.extraModprobeConfig = ''
      options rtw89_pci disable_aspm=y
      options rtw89_8852be disable_aspm=y
    '';
    # networking.wireless.enable = true;
    # networking.networkmanager.enable = false;
    # networking.connman.enable = true;
    # environment.systemPackages = [
    #   pkgs.cmst
    # ];

    time.timeZone = "Europe/Sofia";

    users.users.${ownerProfile.name} = {
      isNormalUser = true;
      description = ownerProfile.name;
      extraGroups = ["networkmanager" "wheel" "dialout" "adbusers"];
    };

    services.udev.extraRules = ''
      ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", MODE="0666", GROUP="dialout"
    '';
  };
}
