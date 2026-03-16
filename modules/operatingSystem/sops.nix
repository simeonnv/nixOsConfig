{
  pkgs,
  ownerProfile,
  ...
}: {
  flake.nixosModules.sops = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      sops
      age
    ];
  };
}
