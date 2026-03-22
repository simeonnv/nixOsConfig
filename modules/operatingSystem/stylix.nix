{pkgs, ...}: {
  flake.nixosModules.stylix = {
    lib,
    pkgs,
    ...
  }: {
    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";

      image = ./../../assets/blueLain.jpg;
      polarity = "dark";

      targets.grub.enable = false;

      iconTheme = {
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
