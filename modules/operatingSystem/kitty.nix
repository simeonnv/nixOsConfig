{pkgs, ...}: {
  flake.nixosModules.kitty = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      kitty.terminfo
      kitty
    ];
  };

  flake.homeModules.kitty = {pkgs, ...}: {
    programs.kitty = {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
      };
    };
  };
}
