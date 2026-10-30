{
  inputs,
  self,
  ownerProfile,
  deployLib,
  lib,
  config,
  ...
}: let
  prodesks = {
    prodesk-server = {
      hostname = "192.168.111.3";
      sshTunnelPort = 2201;
    };
    # prodesk-2 = {
    #   hostname = "192.168.111.4";
    # };
  };

  gatewayHost = config.flake.deploy.nodes.gateway.hostname;

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
          firefox-syncserver
          rathole-client
          mullvad
          syphoria
          forgejo
        ]
        ++ [
          inputs.home-manager.nixosModules.home-manager
          inputs.disko.nixosModules.disko
          ./_disko.nix
          ({...}: {
            networking.hostName = name;
            disko.devices.disk.main.device = lib.mkIf (cfg ? disk) cfg.disk;
            services.rathole.settings.client.services."ssh-${name}".local_addr = "127.0.0.1:22";
          })
        ]
        ++ (cfg.extraModules or []);
    };

  mkNode = name: cfg: {
    hostname = name;
    profiles.system = {
      user = "root";
      sshUser = "simeon";
      path = deployLib.x86_64-linux.activate.nixos self.nixosConfigurations.${name};
    };
  };
in {
  flake.nixosConfigurations = lib.mapAttrs mkProdesk prodesks;
  flake.deploy.nodes = lib.mapAttrs mkNode prodesks;

  flake.nixosModules.gateway-ssh-tunnels = {
    services.rathole.settings.server.services = lib.mapAttrs' (name: cfg:
      lib.nameValuePair "ssh-${name}" {
        bind_addr = "127.0.0.1:${toString cfg.sshTunnelPort}";
      })
    prodesks;
  };

  flake.homeModules.cluster-ssh = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings =
        {
          gateway = {
            HostName = gatewayHost;
            User = ownerProfile.name;
          };
        }
        // lib.mapAttrs (name: cfg: {
          HostName = "127.0.0.1";
          Port = cfg.sshTunnelPort;
          User = ownerProfile.name;
          ProxyJump = "gateway";
          HostKeyAlias = name;
        })
        prodesks;
    };
  };

  flake.nixosModules.prodesk-server = {
    pkgs,
    config,
    ...
  }: let
    mullvadCli = "${config.services.mullvad-vpn.package}/bin/mullvad";
  in {
    services.mullvad-vpn.enableEarlyBootBlocking = lib.mkForce false;
    systemd.services.mullvad-auto-connect.enable = false;

    systemd.services.mullvad-lan-allow = {
      after = ["mullvad-daemon.service"];
      requires = ["mullvad-daemon.service"];
      wantedBy = ["multi-user.target"];
      path = [pkgs.coreutils];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        for _ in $(seq 1 60); do
          ${mullvadCli} status >/dev/null 2>&1 && break
          sleep 1
        done
        ${mullvadCli} lan set allow
        ${mullvadCli} auto-connect set off
      '';
    };

    systemd.services.rathole = {
      after = ["mullvad-daemon.service"];
      wants = ["mullvad-daemon.service"];
      serviceConfig.ExecStartPost = "-+${mullvadCli} split-tunnel add $MAINPID";
    };

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

    services.rathole.settings.client = {
      remote_addr = "51.195.40.164:2333";
      transport.noise.remote_public_key = "y21qMm2k9/9gC60ZX5sgeNpUpL/oKUEdjaRY39GiSDs=";
      services.firefox-sync.local_addr = "127.0.0.1:5000";
    };

    time.timeZone = "Europe/Sofia";

    services.tor = {
      enable = true;
    };

    systemd.services.tor = {
      wants = ["systemd-resolved.service"];
      after = ["systemd-resolved.service"];
    };

    users.users.${ownerProfile.name} = {
      isNormalUser = true;
      description = ownerProfile.name;
      extraGroups = ["networkmanager" "wheel"];
    };
  };
}
