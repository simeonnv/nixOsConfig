{
  inputs,
  self,
  ownerProfile,
  ...
}: {
  flake.nixosConfigurations.cf-sv = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with self.nixosModules;
      [
        nix-cache
        pkgs-stable
        pkgs-multiverse
        cf-sv
        sway
        greeter
        git
        fastfetch
        stylix
        thunar
        zsh
        file-roller
        qimgv
        docker
        nh
        hacking
        qbittorrent
        manix
        libreoffice
        viber
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
        fonts
        devenv
        jujutsu
        ai-slop
        tlp
        mullvad
        cachyos-kernel
      ]
      ++ [
        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.disko
        inputs.stylix.nixosModules.stylix
        ./_disko.nix
      ];
  };

  flake.nixosModules.cf-sv = {pkgs, ...}: {
    nix.settings.experimental-features = ["nix-command" "flakes"];
    hardware.enableAllFirmware = true;
    hardware.cpu.intel.updateMicrocode = true;
    nixpkgs.config.allowUnfree = true;

    hardware.graphics = {
      enable = true;
      extraPackages = [
        pkgs.intel-media-driver
        pkgs.vpl-gpu-rt
      ];
    };
    environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

    services.thermald.enable = true;
    services.udisks2.enable = true;

    services.flatpak.enable = true;
    system.stateVersion = "25.11";
    home-manager.backupFileExtension = "backup";
    home-manager.users.${ownerProfile.name} = {...}: {
      home.username = ownerProfile.name;
      home.homeDirectory = "/home/${ownerProfile.name}";
      home.stateVersion = "25.11";
      services.udiskie.enable = true;
      imports = with self.homeModules; [
        sway
        discord
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
        cluster-ssh
      ];
    };

    boot.loader.grub.enable = true;
    boot.loader.grub.device = "nodev";
    boot.loader.grub.efiSupport = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot";

    programs.nix-ld.enable = true;
    networking.hostName = "cf-sv";
    stylixTheme = "light";
    networking.networkmanager.enable = true;

    time.timeZone = "Europe/Sofia";
    services.upower.enable = true;

    services.logind.settings.Login = {
      HandlePowerKey = "ignore";
      HandlePowerKeyLongPress = "ignore";
    };

    environment.systemPackages = [
      pkgs.usbutils
      pkgs.pciutils
      pkgs.nodejs
    ];

    networking.firewall = {
      allowedTCPPorts = [6567 1420 7060];
      allowedUDPPorts = [6567 1420 7060];
    };

    users.users.${ownerProfile.name} = {
      isNormalUser = true;
      description = ownerProfile.name;
      extraGroups = ["networkmanager" "wheel" "dialout" "adbusers" "cdrom"];
    };

    services.udev.extraRules = ''
      ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", MODE="0666", GROUP="dialout"
    '';
  };
}
