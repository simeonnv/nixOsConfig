{pkgs, ...}: {
  flake.nixosModules.minecraft = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.prismlauncher
    ];
  };
}
