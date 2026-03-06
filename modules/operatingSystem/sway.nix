{pkgs, ...}: {
  flake.nixosModules.sway = {pkgs, ...}: {
    security.polkit.enable = true;
    programs.sway = {
      enable = true;
      xwayland.enable = true;
      extraOptions = [
        "--unsupported-gpu"
      ];
      wrapperFeatures.gtk = true;
    };

    environment.systemPackages = with pkgs; [
      sway
      wl-clipboard
    ];
  };

  flake.homeManager.sway = {lib, ...}: {
    wayland.windowManager.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      config = {
        modifier = "Mod4";
        terminal = "kitty";
        startup = [
          {command = "firefox";}
        ];
      };
    };
  };
}
