{pkgs, ...}: {
  flake.nixosModules.thunar = {pkgs, ...}: {
    programs.thunar.enable = true;
    programs.xfconf.enable = true;
    programs.thunar.plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
    services.gvfs.enable = true;
    services.tumbler.enable = true;
  };
}
