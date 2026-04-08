{pkgs, ...}: {
  flake.nixosModules.steam = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.steam-run
    ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };
}
