{pkgs, ...}: {
  flake.nixosModules.devenv = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.devenv
    ];
  };
}
