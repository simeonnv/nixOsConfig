{pkgs, ...}: {
  flake.nixosModules.fonts = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.font-manager
    ];

    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      dina-font
      proggyfonts
    ];
  };
}
