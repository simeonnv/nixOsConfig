{...}: {
  flake.nixosModules.inkscape = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.inkscape-with-extensions
    ];
  };
}
