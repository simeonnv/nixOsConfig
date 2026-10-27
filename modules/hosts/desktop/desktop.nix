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
        openrazer
        obs-studio
        mullvad
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

    boot.supportedFilesystems = ["ntfs" "zfs"];
    boot.zfs.forceImportRoot = false;
    boot.extraModprobeConfig = "options zfs zfs_arc_max=8589934592";
    networking.hostId = "8d285275";
    services.zfs.autoScrub.enable = true;

    environment.etc.crypttab.text = ''
      cryptdata /dev/disk/by-id/ata-ST4000VN006-3CW104_WW6BHFF7-part1 /root/cryptdata.key luks,nofail
    '';

    systemd.services.zfs-import-data = {
      wants = ["systemd-cryptsetup@cryptdata.service"];
      after = ["systemd-cryptsetup@cryptdata.service"];
    };

    fileSystems."/mnt/data" = {
      device = "data/general";
      fsType = "zfs";
      options = ["nofail"];
    };
    fileSystems."/mnt/data/media" = {
      device = "data/media";
      fsType = "zfs";
      options = ["nofail"];
    };
    fileSystems."/mnt/data/archive" = {
      device = "data/archive";
      fsType = "zfs";
      options = ["nofail"];
    };
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
