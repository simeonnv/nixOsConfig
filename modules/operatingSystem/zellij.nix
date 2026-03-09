{pkgs, ...}: {
  flake.homeModules.zellij = {pkgs, ...}: {
    programs.zellij = {
      enable = true;
      # enableBashIntegration = true;
      # enableZshIntegration = true;
    };
  };
}
