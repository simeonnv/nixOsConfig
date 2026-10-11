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
      (pkgs.appimage-run.override {
        extraPkgs = p: [p.webkitgtk_4_1 p.glib-networking p.libsoup_3];
      })
      pkgs.gamemode
      pkgs.mangohud
      pkgs.steamcmd
      pkgs.gamescope
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
