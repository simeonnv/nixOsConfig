{
  pkgs,
  ownerProfile,
  ...
}: let
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAz6cbpujcaBo5eAb4+c30kaD5T9wUXAtv5XS98BNACI simmeon.nv@proton.me"
  ];
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
