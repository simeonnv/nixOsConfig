{pkgs, ...}: {
  flake.nixosModules.qbittorrent = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.qbittorrent
    ];
  };
}
