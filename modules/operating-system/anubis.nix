{
  self,
  ownerProfile,
  ...
}: {
  flake.nixosModules.anubis = {
    config,
    lib,
    ...
  }: let
    serviceName = name:
      if name == ""
      then "anubis"
      else "anubis-${name}";
    instanceNames = lib.attrNames config.services.anubis.instances;
  in {
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
