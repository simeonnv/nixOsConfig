{...}: {
  flake.nixosModules.cinnamon = {...}: {
    services.xserver.desktopManager.cinnamon.enable = true;
  };
}
