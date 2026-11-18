# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{pkgs, ...}: {
  flake.nixosModules.stylix = {
    lib,
    pkgs,
    config,
    ...
  }: let
    themes = {
      dark = {
        scheme = "rose-pine";
        image = ./../../assets/OneShotRosePine.png;
      };
      light = {
        scheme = "catppuccin-latte";
        image = ./../../assets/GLTStaircase.png;
      };
    };
    theme = themes.${config.stylixTheme};
  in {
    options.stylixTheme = lib.mkOption {
      type = lib.types.enum ["dark" "light"];
      default = "dark";
    };

    config.home-manager.sharedModules = [{home.pointerCursor.enable = true;}];

    config.stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${theme.scheme}.yaml";

      # image = ./../../assets/blueLain.jpg;
      # image = ./../../assets/inabakumori.png;
      # image = ./../../assets/GLTStaircaseRosePine.png;
      image = theme.image;
      polarity = config.stylixTheme;

      targets.grub.enable = false;

      icons = {
        enable = true;
        package = pkgs.papirus-icon-theme;
        dark = "Papirus-Dark";
        light = "Papirus-Light";
      };

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };

      fonts = {
        serif = {
          package = pkgs.ultimate-oldschool-pc-font-pack;
          name = "MxPlus IBM VGA 8x16";
        };

        sansSerif = {
          package = pkgs.ultimate-oldschool-pc-font-pack;
          name = "MxPlus IBM VGA 8x16";
        };

        monospace = {
          package = pkgs.ultimate-oldschool-pc-font-pack;
          name = "MxPlus IBM VGA 8x16";
        };

        sizes = {
          applications = 12;
          desktop = 12;
          popups = 12;
          terminal = 12;
        };

        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };
    };
  };
}
