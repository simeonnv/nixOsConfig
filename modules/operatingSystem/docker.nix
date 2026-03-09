{
  pkgs,
  ownerProfile,
  ...
}: {
  flake.nixosModules.docker = {pkgs, ...}: {
    virtualisation.docker.enable = true;

    environment.systemPackages = with pkgs; [
      docker-compose
    ];

    users.users.${ownerProfile.name}.extraGroups = ["docker"];
  };
}
