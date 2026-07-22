{
  inputs,
  self,
  ownerProfile,
  ...
}: {
  flake.nixosConfigurations.thinkpad_t480 = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with self.nixosModules;
      [
        pkgs-stable
        thinkpad_t480
        sway
        greeter
        git
        fastfetch
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
        printer3d
        devenv
        jujutsu
        ai-slop
        tlp
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

  flake.nixosModules.thinkpad_t480 = {pkgs, ...}: {
    imports = [
      inputs.nixos-06cb-009a-fingerprint-sensor.nixosModules."06cb-009a-fingerprint-sensor"
    ];

    services."06cb-009a-fingerprint-sensor" = {
      enable = true;
      backend = "python-validity";
    };

    security.pam.services = let
      fprintArgs = ["timeout=10" "max-tries=1"];
      passwordFirstFprint = {
        fprintAuth = true;
        rules.auth.fprintd = {
          order = 12000;
          args = fprintArgs;
        };
      };
    in {
      sudo = {
        fprintAuth = true;
        rules.auth.fprintd.args = fprintArgs;
      };
      swaylock = passwordFirstFprint;
      greetd = passwordFirstFprint;
    };

    nix.settings.experimental-features = ["nix-command" "flakes"];
    hardware.enableAllFirmware = true;
    nixpkgs.config.allowUnfree = true;

    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
    boot.kernelParams = ["pcie_aspm=off"];

    services.udisks2.enable = true;

    services.flatpak.enable = true;
    system.stateVersion = "25.11";
    # imports = [./_hardware-configuration.nix];
    home-manager.backupFileExtension = "backup";
    home-manager.users.${ownerProfile.name} = {pkgs, ...}: {
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
      ];
    };

    boot.loader.grub.enable = true;
    boot.loader.grub.device = "nodev";
    boot.loader.grub.efiSupport = true;
    # boot.loader.systemd-boot.enable = false;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot";

    programs.nix-ld.enable = true;
    networking.hostName = "t480";
    networking.networkmanager.enable = true;
    # networking.wireless.enable = true;
    # networking.networkmanager.enable = false;
    # networking.connman.enable = true;
    # environment.systemPackages = [
    #   pkgs.cmst
    # ];

    time.timeZone = "Europe/Sofia";
    services.upower.enable = true;

    environment.systemPackages = [
      pkgs.usbutils
      pkgs.nodejs
    ];

    networking.firewall = {
      allowedTCPPorts = [6567 1420 7060];
      allowedUDPPorts = [6567 1420 7060];
    };

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
