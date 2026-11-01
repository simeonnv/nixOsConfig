let
  root = "/srv/jellyfin";
  requestDomain = "request.fravs.org";
  seerrPort = 5055;
  qbittorrentPort = 8081;
  noLogin = {
    auth.method = "External";
  };
in {
  flake.nixosModules.arr = {lib, ...}: let
    stateDir = user: {
      mode = "0700";
      inherit user;
      group = "media";
    };
  in {
    services.qbittorrent = {
      enable = true;
      group = "media";
      profileDir = "${root}/qbittorrent";
      webuiPort = qbittorrentPort;
      serverConfig = {
        LegalNotice.Accepted = true;
        BitTorrent.Session = {
          DefaultSavePath = "${root}/downloads";
          TempPath = "${root}/downloads/incomplete";
          TempPathEnabled = true;
        };
        Preferences.WebUI = {
          Address = "127.0.0.1";
          LocalHostAuth = false;
        };
      };
    };

    services.sonarr = {
      enable = true;
      group = "media";
      dataDir = "${root}/sonarr";
      settings = noLogin;
    };

    services.radarr = {
      enable = true;
      group = "media";
      dataDir = "${root}/radarr";
      settings = noLogin;
    };

    services.bazarr = {
      enable = true;
      group = "media";
      dataDir = "${root}/bazarr";
    };

    services.prowlarr = {
      enable = true;
      dataDir = "${root}/prowlarr";
      settings = noLogin;
    };

    services.flaresolverr.enable = true;

    services.seerr = {
      enable = true;
      port = seerrPort;
      stateRevision = 1;
    };

    systemd.tmpfiles.settings.arr = {
      "${root}/qbittorrent"."d" = stateDir "qbittorrent";
      "${root}/sonarr"."d" = stateDir "sonarr";
      "${root}/radarr"."d" = stateDir "radarr";
      "${root}/downloads"."d" = {
        mode = "2775";
        user = "qbittorrent";
        group = "media";
      };
      "${root}/seerr"."d" = {
        mode = "0700";
        user = "root";
        group = "root";
      };
    };

    systemd.mounts = [
      {
        what = "${root}/seerr";
        where = "/var/lib/private/seerr";
        options = "bind";
        wantedBy = ["local-fs.target"];
      }
    ];

    systemd.services = {
      qbittorrent.serviceConfig.UMask = "0002";
      sonarr.serviceConfig.UMask = lib.mkForce "0002";
      radarr.serviceConfig.UMask = lib.mkForce "0002";
      bazarr.serviceConfig.UMask = "0002";
    };

    services.rathole.settings.client.services.seerr.local_addr = "127.0.0.1:${toString seerrPort}";
  };

  flake.nixosModules.arr-gateway = {
    services.rathole.settings.server.services.seerr.bind_addr = "127.0.0.1:${toString seerrPort}";

    services.caddy.virtualHosts.${requestDomain}.extraConfig = ''
      reverse_proxy 127.0.0.1:${toString seerrPort}
    '';
  };
}
