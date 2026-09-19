{...}: {
  flake.nixosModules.qimgv = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.qimgv
    ];
  };
}
