{ config, pkgs, ... }:

{
  imports = [ ../../configs/generics ];

  home.username = "simeon";
  home.homeDirectory = "/home/simeon";

  home.stateVersion = "25.11"; 

  home.packages = with pkgs; [
  ];

  # Basic dotfile management
  programs.bash.enable = true;
  programs.home-manager.enable = true;

}
