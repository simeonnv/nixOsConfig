{
  pkgs,
  ownerProfile,
  ...
}: {
  flake.nixosModules.libreoffice = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      libreoffice
    ];
  };
}
