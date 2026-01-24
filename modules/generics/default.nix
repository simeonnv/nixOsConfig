{ config, pkgs, ... }:

{
  imports = [
    ./cinnamon
    ./sway
  ];
  
  environment.systemPackages = with pkgs; [
    wget
    xclip
    wl-clip-persist
    wl-clipboard
    cliphist
  ];
}
