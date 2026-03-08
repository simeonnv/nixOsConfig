{pkgs, ...}: {
  flake.nixosModules.file-roller = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.file-roller
    ];
  };
}
