{
  flake.nixosModules.obs-studio = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.obs-studio
    ];
  };
}
