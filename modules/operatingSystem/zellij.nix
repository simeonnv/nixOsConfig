{pkgs, ...}: {
  flake.homeModules.zellij = {pkgs, ...}: {
    programs.zellij = {
      enable = true;
      settings = {
        default_layout = "compact";
      };
    };
  };
}
