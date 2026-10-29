let
  domain = "git.fravs.org";
  httpPort = 3000;
  sshPort = 2223;
in {
  flake.nixosModules.forgejo = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.services.forgejo;
  in {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "forgejo" ''
        exec /run/wrappers/bin/sudo -u ${cfg.user} ${pkgs.lib.getExe cfg.package} --work-path ${cfg.stateDir} "$@"
      '')
    ];

    services.forgejo = {
      enable = true;
      database.type = "sqlite3";
      lfs.enable = true;
      settings = {
        server = {
          DOMAIN = domain;
          ROOT_URL = "https://${domain}/";
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = httpPort;
          START_SSH_SERVER = true;
          SSH_DOMAIN = domain;
          SSH_PORT = sshPort;
          SSH_LISTEN_HOST = "127.0.0.1";
          SSH_LISTEN_PORT = sshPort;
        };
        service.DISABLE_REGISTRATION = true;
        session.COOKIE_SECURE = true;
        actions.ENABLED = true;
      };
    };

    services.rathole.settings.client.services = {
      forgejo-http.local_addr = "127.0.0.1:${toString httpPort}";
      forgejo-ssh.local_addr = "127.0.0.1:${toString sshPort}";
    };
  };

  flake.nixosModules.forgejo-gateway = {
    services.rathole.settings.server.services = {
      forgejo-http.bind_addr = "127.0.0.1:${toString httpPort}";
      forgejo-ssh.bind_addr = "0.0.0.0:${toString sshPort}";
    };

    services.anubis.instances.forgejo = {
      settings.TARGET = "http://127.0.0.1:${toString httpPort}";
      settings.DIFFICULTY = 6;
      policy.extraBots = [
        {import = "(data)/clients/git.yaml";}
        {import = "(data)/apps/gitea-rss-feeds.yaml";}
      ];
      policy.settings = {
        store = {
          backend = "bbolt";
          parameters.path = "/var/lib/anubis-forgejo/anubis.bdb";
        };
        thresholds = [
          {
            name = "challenge";
            expression = "weight > 0";
            action = "CHALLENGE";
            challenge = {
              algorithm = "fast";
              difficulty = 6;
            };
          }
        ];
      };
    };

    services.caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy unix//run/anubis/anubis-forgejo/anubis.sock {
        header_up X-Real-Ip {client_ip}
      }
    '';

    networking.firewall.allowedTCPPorts = [sshPort];
  };
}
