{
  pkgs,
  ownerProfile,
  ...
}: {
  flake.nixosModules.i2pd = {pkgs, ...}: {
    services.i2pd = {
      enable = true;
      bandwidth = 64;
      port = 31835;
      upnp.enable = false;
    };

    networking.firewall = {
      allowedTCPPorts = [31835];
      allowedUDPPorts = [31835];
    };
  };
}
