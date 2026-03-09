{
  pkgs,
  ownerProfile,
  ...
}: {
  flake.nixosModules.ssh = {pkgs, ...}: {
    networking.firewall.allowedTCPPorts = [22];
    services.openssh = {
      enable = true;
    };
  };
}
