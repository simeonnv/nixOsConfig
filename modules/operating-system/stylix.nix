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
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
        };

        sansSerif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
        };

        monospace = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans Mono";
        };

        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };
    };
  };
}
