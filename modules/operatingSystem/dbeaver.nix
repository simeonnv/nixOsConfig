{pkgs, ...}: {
  flake.nixosModules.dbeaver = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.dbeaver-bin
    ];
  };
}
