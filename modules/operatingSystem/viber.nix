{...}: {
  flake.nixosModules.viber = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.viber
    ];
  };
}
