{ config, ... }:
{
  flake = {
    meta.owner = {
      email = "simmeon.nv@proton.me";
      name = "simeon";
      username = "simeon";
    };

    modules = {
      nixos.base = {
        users.users.${config.flake.meta.owner.username} = {
          isNormalUser = true;
          initialPassword = "";
          extraGroups = [ "input" ];
        };

        nix.settings.trusted-users = [ config.flake.meta.owner.username ];
      };
    };
  };
}
