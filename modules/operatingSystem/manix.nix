{...}: {
  flake.nixosModules.manix = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.manix
    ];
  };
}
