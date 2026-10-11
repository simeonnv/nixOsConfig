{
  self,
  ownerProfile,
  ...
}: {
  flake.nixosModules.anubis = {
    config,
    lib,
    pkgs,
    ...
  }: let
    serviceName = name:
      if name == ""
      then "anubis"
      else "anubis-${name}";
    instanceNames = lib.attrNames config.services.anubis.instances;
    anubisVersion = "1.28.1";
  in {
    services.anubis.package =
      lib.warnIf (lib.versionAtLeast pkgs.anubis.version anubisVersion)
      "nixpkgs anubis (${pkgs.anubis.version}) caught up with the override (${anubisVersion}); remove services.anubis.package override in modules/operating-system/anubis.nix"
      (pkgs.anubis.overrideAttrs (old: {
        version = anubisVersion;
        src = pkgs.fetchurl {
          url = "https://github.com/TecharoHQ/anubis/releases/download/v${anubisVersion}/anubis-src-vendor-npm-${anubisVersion}.tar.gz";
          hash = "sha256-3Rtg4n0/M7uRoSmawHNj4l+vI2H1O89JHDzg7Kp/qmQ=";
        };
        vendorHash = null;
        npmDeps = null;
        nativeBuildInputs = [old.passthru.go];
        postPatch = "";
        preBuild = "";
        doCheck = false;
        ldflags = [
          "-s"
          "-w"
          "-X=github.com/TecharoHQ/anubis.Version=v${anubisVersion}"
          "-extldflags=-static"
        ];
      }));

    sops.secrets.anubis_ed25519_key = {
      sopsFile = self + /secrets/anubis.yaml;
      owner = config.services.anubis.defaultOptions.user;
      group = config.services.anubis.defaultOptions.group;
      restartUnits = map (name: "${serviceName name}.service") instanceNames;
    };

    services.anubis.defaultOptions.settings = {
      SERVE_ROBOTS_TXT = true;
      OG_PASSTHROUGH = true;
      WEBMASTER_EMAIL = ownerProfile.email;
      ED25519_PRIVATE_KEY_HEX_FILE = config.sops.secrets.anubis_ed25519_key.path;
    };

    systemd.services =
      lib.genAttrs' instanceNames (name:
        lib.nameValuePair (serviceName name) {
          serviceConfig.StateDirectory = serviceName name;
        })
      // {
        caddy.serviceConfig.SupplementaryGroups = [config.users.groups.anubis.name];
      };

    users.users.caddy.extraGroups = [config.users.groups.anubis.name];
  };
}
