{
  inputs,
  self,
  ownerProfile,
  ...
}: {
  flake.nixosConfigurations.thinkpad-t480 = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with self.nixosModules;
      [
        pkgs-stable
        pkgs-multiverse
        thinkpad-t480
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
        cachyos-kernel
      ]
      ++ [
        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.disko
        inputs.stylix.nixosModules.stylix
        ./_disko.nix
      ];
  };

  flake.nixosModules.thinkpad_t480 = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      inputs.nixos-06cb-009a-fingerprint-sensor.nixosModules."06cb-009a-fingerprint-sensor"
    ];

    services."06cb-009a-fingerprint-sensor" = {
      enable = true;
      backend = "python-validity";
    };

    systemd.services = let
      sleepTargets = [
        "suspend.target"
        "hibernate.target"
        "hybrid-sleep.target"
        "suspend-then-hibernate.target"
      ];
    in {
      open-fprintd-suspend.wantedBy = sleepTargets;

      open-fprintd-resume = {
        wantedBy = sleepTargets;
        serviceConfig.ExecStart = lib.mkForce [
          ""
          (pkgs.writeShellScript "open-fprintd-resume" ''
            set -u
            systemctl=${pkgs.systemd}/bin/systemctl

            for attempt in $(seq 1 10); do
              sleep 2
              echo "restarting fingerprint driver stack (attempt $attempt)"
              $systemctl restart open-fprintd.service python3-validity.service
              sleep 4
              if $systemctl is-active --quiet python3-validity.service; then
                echo "fingerprint sensor back online"
                exit 0
              fi
            done

            echo "fingerprint sensor did not come back after resume" >&2
            exit 1
          '')
        ];
      };
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

    services.udisks2.enable = true;

    services.flatpak.enable = true;
    system.stateVersion = "25.11";
    # imports = [./_hardware-configuration.nix];
    home-manager.backupFileExtension = "backup";
    home-manager.users.${ownerProfile.name} = {
      pkgs,
      lib,
      ...
    }: {
      home.username = ownerProfile.name;
      home.homeDirectory = "/home/${ownerProfile.name}";
      home.stateVersion = "25.11";
      services.udiskie.enable = true;
      wayland.windowManager.sway = {
        config.input."type:touchpad".tap = lib.mkForce "disabled";
        extraConfig = ''
          bindgesture pinch:inward nop
          bindgesture pinch:outward nop
        '';
      };
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
      # the 06cb:009a sensor re-enumerates on resume; restart the driver when it reappears
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="06cb", ATTR{idProduct}=="009a", TAG+="systemd", ENV{SYSTEMD_WANTS}+="python3-validity.service"
    '';
  };
}
