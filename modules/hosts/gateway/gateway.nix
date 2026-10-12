{
  inputs,
  self,
  ownerProfile,
  deployLib,
  ...
}: {
  flake.nixosConfigurations.gateway = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with self.nixosModules;
      [
        pkgs-stable
        pkgs-multiverse
        gateway
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
        caddy
        anubis
        manifesto
        rathole-server
        gateway-ssh-tunnels
        syphoria-gateway
      ]
      ++ [
        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.disko
        ./_disko.nix
      ];
  };

  flake.deploy.nodes.gateway = {
    hostname = "51.195.40.164";
    profiles.system = {
      user = "root";
      sshUser = "simeon";
      path = deployLib.x86_64-linux.activate.nixos self.nixosConfigurations.gateway;
    };
  };

  flake.nixosModules.gateway = {modulesPath, ...}: {
    imports = [(modulesPath + "/profiles/qemu-guest.nix")];

    nix.settings.experimental-features = ["nix-command" "flakes"];
    hardware.enableAllFirmware = true;
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

    boot.loader.grub.enable = true;
    # boot.kernelParams = ["consoleblank=60"];

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

    networking.hostName = "gateway";
    networking.networkmanager.enable = true;

    services.anubis.instances.manifesto = {
      settings.TARGET = "http://127.0.0.1:8080";
      settings.DIFFICULTY = 5;
      policy.settings = {
        store = {
          backend = "bbolt";
          parameters.path = "/var/lib/anubis-manifesto/anubis.bdb";
        };
        thresholds = [
          {
            name = "challenge";
            expression = "weight > 0";
            action = "CHALLENGE";
            challenge = {
              algorithm = "fast";
              difficulty = 5;
            };
          }
        ];
      };
    };

    services.caddy.virtualHosts."manifesto.fravs.org".extraConfig = ''
      reverse_proxy unix//run/anubis/anubis-manifesto/anubis.sock {
        header_up X-Real-Ip {client_ip}
      }
    '';

    services.caddy.virtualHosts."sync.fravs.org".extraConfig = ''
      reverse_proxy 127.0.0.1:5000
    '';

    services.rathole.settings.server = {
      bind_addr = "0.0.0.0:2333";
      services.firefox-sync.bind_addr = "127.0.0.1:5000";
    };
    networking.firewall.allowedTCPPorts = [2333];

    time.timeZone = "Europe/Sofia";

    users.users.${ownerProfile.name} = {
      isNormalUser = true;
      description = ownerProfile.name;
      extraGroups = ["networkmanager" "wheel"];
    };
  };
}
