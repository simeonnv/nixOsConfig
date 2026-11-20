# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT
{self, ...}: let
  domain = "git.fravs.org";
  httpPort = 3000;
  sshPort = 2223;
in {
  flake.nixosModules.forgejo = {
    config,
    pkgs,
    pkgs-multiverse,
    ...
  }: let
    cfg = config.services.forgejo;
    font = "${pkgs.ultimate-oldschool-pc-font-pack}/share/fonts/truetype/MxPlus_IBM_VGA_8x16.ttf";
    fontTools = pkgs.python3.withPackages (p: [p.fonttools p.brotli]);
    logo = self.lib.fravsLogo pkgs;
    customPublic = pkgs.runCommand "forgejo-custom-public" {nativeBuildInputs = [fontTools];} ''
      mkdir -p $out/assets/css $out/assets/fonts $out/assets/img
      cp ${./../../assets/forgejo/theme-rose-pine.css} $out/assets/css/theme-rose-pine.css
      pyftsubset ${font} --unicodes='*' --glyphs='*' --no-hinting \
        --drop-tables+=EBDT,EBLC,EBSC,bdat,bloc,FFTM,prop \
        --flavor=woff2 --output-file=$out/assets/fonts/MxPlus_IBM_VGA_8x16.woff2

      cp ${logo}/logo.png ${logo}/logo.svg ${logo}/favicon.png ${logo}/favicon.svg $out/assets/img/
      cp ${logo}/favicon.png $out/assets/img/apple-touch-icon.png
    '';
    customTemplates = pkgs.runCommand "forgejo-custom-templates" {} ''
      mkdir -p $out
      cp ${./../../assets/forgejo/home.tmpl} $out/home.tmpl
    '';
  in {
    systemd.tmpfiles.rules = [
      "L+ '${cfg.customDir}/public' - - - - ${customPublic}"
      "L+ '${cfg.customDir}/templates' - - - - ${customTemplates}"
    ];

    systemd.services.forgejo.restartTriggers = [customPublic customTemplates];

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "forgejo" ''
        exec /run/wrappers/bin/sudo -u ${cfg.user} ${pkgs.lib.getExe cfg.package} --work-path ${cfg.stateDir} "$@"
      '')
    ];

    services.forgejo = {
      enable = true;
      package = pkgs-multiverse.version "forgejo" "17.0.1";
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
        ui = {
          THEMES = "rose-pine";
          DEFAULT_THEME = "rose-pine";
        };
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
      settings.DIFFICULTY = 5;
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
              difficulty = 5;
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
