{
  pkgs,
  ownerProfile,
  ...
}: {
  flake.nixosModules.i2pd = {pkgs, ...}: {
    services.i2pd = {
      enable = true;
      settings = {
        bandwidth = 64;
        port = 31835;
        upnp.enabled = false;
      };
    };

    networking.firewall = {
      allowedTCPPorts = [31835];
      allowedUDPPorts = [31835];
    };
  };
}
