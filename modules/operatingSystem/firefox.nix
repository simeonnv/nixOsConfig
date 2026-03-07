{pkgs, ...}: {
  flake.homeModules.firefox = {
    lib,
    pkgs,
    ...
  }: {
    programs.firefox = {
      enable = true;
      profiles.simeon = {
        name = "simeon";
        isDefault = true;
      };
    };
  };
}
