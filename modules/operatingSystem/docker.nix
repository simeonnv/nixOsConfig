{
  pkgs,
  ownerProfile,
  ...
}: {
  flake.nixosModules.docker = {pkgs, ...}: {
    virtualisation.docker.enable = true;

    environment.systemPackages = with pkgs; [
      docker-compose
      k3d
      kubectl
      kubernetes-helm
    ];

    users.users.${ownerProfile.name}.extraGroups = ["docker"];
    boot.kernelModules = ["ip_tables"];
  };
}
