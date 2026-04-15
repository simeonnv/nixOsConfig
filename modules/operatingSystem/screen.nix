{pkgs, ...}: {
  flake.nixosModules.screen = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.screen
    ];
  };
}
