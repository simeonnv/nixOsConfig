{ownerProfile, ...}: let
  domain = "jellyfin.fravs.org";
  httpPort = 8096;
  root = "/srv/jellyfin";
  mediaDir = {
    mode = "2775";
    user = ownerProfile.name;
    group = "media";
  };
in {
  flake.nixosModules.jellyfin = {
    hardware.graphics.enable = true;

    services.jellyfin = {
      enable = true;
      dataDir = "${root}/data";
      cacheDir = "${root}/cache";
      forceEncodingConfig = true;
      hardwareAcceleration = {
        enable = true;
        type = "vaapi";
        device = "/dev/dri/renderD128";
      };
      transcoding = {
        enableHardwareEncoding = true;
        hardwareEncodingCodecs.hevc = true;
        hardwareDecodingCodecs = {
          h264 = true;
          hevc = true;
          hevc10bit = true;
          vp9 = true;
          mpeg2 = true;
          vc1 = true;
        };
      };
    };

    users.groups.media = {};
    users.users.jellyfin.extraGroups = ["media"];
    users.users.${ownerProfile.name}.extraGroups = ["media"];

    systemd.tmpfiles.settings.jellyfinRoot = {
      ${root}."d" = {
        mode = "0755";
        user = "root";
        group = "root";
      };
      "${root}/media"."d" = mediaDir;
      "${root}/media/movies"."d" = mediaDir;
      "${root}/media/shows"."d" = mediaDir;
    };

    systemd.services.jellyfin.unitConfig.RequiresMountsFor = [root];

    services.rathole.settings.client.services.jellyfin.local_addr = "127.0.0.1:${toString httpPort}";
  };

  flake.nixosModules.jellyfin-gateway = {
    services.rathole.settings.server.services.jellyfin.bind_addr = "127.0.0.1:${toString httpPort}";

    services.caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy 127.0.0.1:${toString httpPort}
    '';
  };
}
