{
  inputs,
  ownerProfile,
  ...
}: {
  flake.nixosModules.openrazer = {
    pkgs,
    lib,
    ...
  }: {
    hardware.openrazer.enable = true;
    environment.systemPackages = with pkgs; [
      openrazer-daemon
      polychromatic
    ];
    users.users.${ownerProfile.name}.extraGroups = ["openrazer"];
  };
}
