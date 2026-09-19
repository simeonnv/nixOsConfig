{pkgs, ...}: {
  flake.nixosModules.winboat = {pkgs, ...}: {
    # winboat ships an EOL electron
    nixpkgs.config.permittedInsecurePackages = ["electron-40.10.5"];

    environment.systemPackages = [
      pkgs.winboat
    ];
  };
}
