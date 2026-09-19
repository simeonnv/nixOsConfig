{
  inputs,
  self,
  ownerProfile,
  deployLib,
  lib,
  ...
}: let
  prodesks = {
    prodesk-server = {
      hostname = "192.168.111.3";
    };
    # prodesk-2 = {
    #   hostname = "192.168.111.4";
    # };
  };

  mkProdesk = name: cfg:
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = with self.nixosModules;
        [
          pkgs-stable
          pkgs-multiverse
          prodesk-server
          git
          fastfetch
          zsh
          docker
          ssh
          kitty
          sops
          rust
          screen
          jujutsu
          sudo-server
          deploy-target
        ]
        ++ [
          inputs.home-manager.nixosModules.home-manager
          inputs.disko.nixosModules.disko
          ./_disko.nix
          ({...}: {
            networking.hostName = name;
            disko.devices.disk.main.device = lib.mkIf (cfg ? disk) cfg.disk;
          })
        ]
        ++ (cfg.extraModules or []);
    };

  mkNode = name: cfg: {
    inherit (cfg) hostname;
    profiles.system = {
      user = "root";
      sshUser = "simeon";
      path = deployLib.x86_64-linux.activate.nixos self.nixosConfigurations.${name};
    };
  };
in {
  flake.nixosConfigurations = lib.mapAttrs mkProdesk prodesks;
  flake.deploy.nodes = lib.mapAttrs mkNode prodesks;

  flake.nixosModules.prodesk-server = {
    nix.settings.experimental-features = ["nix-command" "flakes"];
    hardware.enableAllFirmware = true;
    hardware.cpu.amd.updateMicrocode = true;
    networking.firewall.enable = true;

    system.stateVersion = "25.11";
    home-manager.backupFileExtension = "backup";
    home-manager.users.${ownerProfile.name} = {
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
      ];
    };

    nixpkgs.config.allowUnfree = true;

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelParams = ["consoleblank=60"];

    services.logind.settings = {
      Login = {
        LidSwitchIgnoreInhibit = "no";
        HandleLidSwitch = "ignore";
        HandleLidSwitchExternalPower = "ignore";
        HandleLidSwitchDocked = "ignore";
      };
    };
    powerManagement.enable = true;
    systemd.targets.sleep.enable = false;
    systemd.targets.suspend.enable = false;
    systemd.targets.hibernate.enable = false;
    systemd.targets.hybrid-sleep.enable = false;

    networking.hostName = lib.mkDefault "prodesk-server";
    networking.networkmanager.enable = true;

    time.timeZone = "Europe/Sofia";

    users.users.${ownerProfile.name} = {
      isNormalUser = true;
      description = ownerProfile.name;
      extraGroups = ["networkmanager" "wheel"];
    };
  };
}
