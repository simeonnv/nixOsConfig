{pkgs, ...}: {
  flake.homeModules.direnv = {
    lib,
    pkgs,
    ...
  }: {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
