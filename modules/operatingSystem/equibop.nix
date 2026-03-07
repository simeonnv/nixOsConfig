{pkgs, ...}: {
  flake.nixosModules.equibop = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.equibop
    ];
  };
}
