{self, ...}: let
  mkRathole = role: {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.rathole;
    toml = pkgs.formats.toml {};
    serviceNames = lib.attrNames (cfg.settings.${role}.services or {});

    credentials =
      lib.recursiveUpdate {
        ${role}.services = lib.genAttrs serviceNames (_: {
          token = config.sops.placeholder.rathole_token;
        });
      } (lib.optionalAttrs (role == "server") {
        server.transport.noise.local_private_key = config.sops.placeholder.rathole_noise_private_key;
      });
    credentialsTemplate = toml.generate "rathole-credentials.toml" credentials;
  in {
    options.services.rathole.sopsFile = lib.mkOption {
      type = lib.types.path;
      default = self + /secrets/rathole.yaml;
      description = ''
        sops file holding `rathole_token` (both roles) and
        `rathole_noise_private_key` (server only).
      '';
    };

    config = {
      assertions = [
        {
          assertion = serviceNames != [];
          message = "services.rathole.settings.${role}.services must declare at least one service";
        }
      ];

      sops.secrets.rathole_token = {
        sopsFile = cfg.sopsFile;
        restartUnits = ["rathole.service"];
      };

      sops.secrets.rathole_noise_private_key = lib.mkIf (role == "server") {
        sopsFile = cfg.sopsFile;
        restartUnits = ["rathole.service"];
      };

      sops.templates."rathole-credentials.toml" = {
        content = builtins.readFile credentialsTemplate;
        restartUnits = ["rathole.service"];
      };

      services.rathole = {
        enable = true;
        inherit role;
        credentialsFile = config.sops.templates."rathole-credentials.toml".path;
        settings.${role}.transport.type = lib.mkDefault "noise";
      };
    };
  };
in {
  flake.nixosModules.rathole-server = mkRathole "server";
  flake.nixosModules.rathole-client = mkRathole "client";
}
