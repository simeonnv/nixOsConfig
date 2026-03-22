{...}: {
  flake.nixosModules.telegram = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [telegram-desktop];
  };
}
