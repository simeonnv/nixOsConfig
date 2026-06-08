{pkgs, ...}: {
  flake.nixosModules.steam = {pkgs, ...}: {
    services.flatpak.enable = true;
    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
      config.common.default = "*";
    };

    environment.systemPackages = [
      pkgs.steam-run
      pkgs.appimage-run
      pkgs.gamemode
      pkgs.mangohud
      pkgs.steamcmd
    ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      protontricks.enable = true;
    };
  };
}
