{inputs, ...}: {
  flake.nixosModules.manix = {pkgs, ...}: {
    nixpkgs.overlays = [
      (final: prev: {
        manix = inputs.manix.packages.${pkgs.system}.manix;
      })
    ];

    environment.systemPackages = [
      pkgs.manix
    ];
  };
}
