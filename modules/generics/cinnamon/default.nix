{ config, pkgs, lib, ... }:

{
  services.xserver = lib.mkIf config.services.xserver.enable {
    desktopManager.cinnamon.enable = true;
  };
}
