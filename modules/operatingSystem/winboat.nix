{pkgs, ...}: {
  flake.nixosModules.winboat = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.winboat
    ];
  };
}
