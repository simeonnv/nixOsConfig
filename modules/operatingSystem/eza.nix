{pkgs, ...}: {
  flake.homeModules.eza = {...}: {
    programs.eza = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
