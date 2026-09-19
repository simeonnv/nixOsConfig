{ownerProfile, ...}: {
  flake.nixosModules.caddy = {...}: {
    services.caddy = {
      enable = true;
      email = ownerProfile.email;
    };

    networking.firewall.allowedTCPPorts = [80 443];
  };
}
