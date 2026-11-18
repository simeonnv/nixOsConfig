# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT
{
  inputs,
  self,
  ownerProfile,
  ...
}: {
  flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with self.nixosModules;
      [
        nix-cache
        pkgs-stable
        pkgs-multiverse
        desktop
        sway
        niri
        power-auth
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
        nvidia
        nh
        hacking
        qbittorrent
        manix
        addlicense
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
        winboat
        blender
        devenv
        jujutsu
        ai-slop
        cachyos-kernel
        kicad
        atopile
        openrazer
        obs-studio
        mullvad
        metrolist
        ssh
        rathole-client
      ]
      ++ [
        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.disko
        inputs.stylix.nixosModules.stylix
        ./_disko.nix
      ];
  };

  flake.nixosModules.desktop = {pkgs, ...}: {
    nix.settings.experimental-features = ["nix-command" "flakes"];
    hardware.enableAllFirmware = true;
    nixpkgs.config.allowUnfree = true;

    services.udisks2.enable = true;

    boot.supportedFilesystems = ["ntfs"];
    networking.hostId = "8d285275";

    fileSystems."/mnt/windows" = {
      device = "/dev/disk/by-uuid/FC6833A968336216";
      fsType = "ntfs-3g";
      options = ["rw" "nofail" "uid=1000" "gid=100" "umask=022" "windows_names"];
    };

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
        niri
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
        yt-dlp
      ];
    };

    boot.loader.grub.enable = true;
    boot.loader.grub.device = "nodev";
    boot.loader.grub.efiSupport = true;
    boot.loader.grub.efiInstallAsRemovable = true;
    # boot.loader.systemd-boot.enable = false;
    boot.loader.efi.canTouchEfiVariables = false;
    boot.loader.efi.efiSysMountPoint = "/boot";

    programs.nix-ld.enable = true;
    networking.hostName = "desktop";
    networking.networkmanager.enable = true;
    # networking.wireless.enable = true;
    # networking.networkmanager.enable = false;
    # networking.connman.enable = true;
    # environment.systemPackages = [
    #   pkgs.cmst
    # ];

    services.rathole.settings.client = {
      remote_addr = "51.195.40.164:2333";
      transport.noise.remote_public_key = "y21qMm2k9/9gC60ZX5sgeNpUpL/oKUEdjaRY39GiSDs=";
      services.ssh-desktop.local_addr = "127.0.0.1:22";
    };

    time.timeZone = "Europe/Sofia";

    environment.systemPackages = [
      pkgs.usbutils
      pkgs.smartmontools
      pkgs.gptfdisk
      pkgs.claude-code
      pkgs.nodejs
    ];

    networking.firewall = {
      allowedTCPPorts = [6567 1420 7060];
      allowedUDPPorts = [6567 1420 7060];
    };
    # services.zerotierone = {
    #   enable = true;
    #   joinNetworks = [
    #     "88503383903b9acf"
    #   ];
    # };

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
