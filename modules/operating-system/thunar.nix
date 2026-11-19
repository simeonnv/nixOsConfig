# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

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
    home-manager.sharedModules = [
      {
        stylix.targets.gtk.extraCss = ''
          window.thunar, window.thunar * { border-radius: 0; }
          window.thunar .view:selected,
          window.thunar iconview:selected,
          window.thunar treeview.view:selected,
          window.thunar flowbox flowboxchild:selected,
          window.thunar placessidebar row:selected,
          window.thunar row:selected {
            background-color: @accent_bg_color;
            color: @accent_fg_color;
            border-radius: 0;
          }
          window.thunar .standard-view .view.cell:selected:not(treeview) {
            background-color: transparent;
            color: @view_fg_color;
            border: 2px solid @accent_bg_color;
            border-radius: 0;
          }
        '';
      }
    ];
  };
}
