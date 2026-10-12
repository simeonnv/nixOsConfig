{
  pkgs,
  ownerProfile,
  ...
}: let
  authorizedKeys = [ownerProfile.sshKey];
in {
  flake.nixosModules.ssh = {pkgs, ...}: {
    networking.firewall.allowedTCPPorts = [22];
    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "prohibit-password";
    };

    users.users.root.openssh.authorizedKeys.keys = authorizedKeys;
    users.users.${ownerProfile.name}.openssh.authorizedKeys.keys = authorizedKeys;
  };
}
