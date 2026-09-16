{
  flake.nixosModules.signal = {pkgs-multiverse, ...}: {
    environment.systemPackages = [
      (pkgs-multiverse.version "signal-desktop" "8.25.0")
    ];
  };
}
