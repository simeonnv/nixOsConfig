{pkgs, ...}: {
  flake.nixosModules.steam = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.steam-run
      pkgs.appimage-run
      pkgs.gamemode
      pkgs.mangohud
    ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };
}
