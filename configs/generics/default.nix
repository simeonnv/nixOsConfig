{ config, pkgs, ... }:

{
  imports = [
    ./helix
    ./floorp
    ./yazi
    ./git
    ./sway
  ];

  # wayland clipboard crap
  home.packages = with pkgs; [
    wl-clip-persist
    wl-clipboard
    cliphist
  ];
  services.cliphist.enable = true;
  services.wl-clip-persist.enable = true;
}
