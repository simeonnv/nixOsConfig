{pkgs, ...}: {
  flake.nixosModules.nmap = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.nmap
    ];
  };
}
