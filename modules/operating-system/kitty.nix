# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{pkgs, ...}: {
  flake.nixosModules.kitty = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      kitty.terminfo
      kitty
    ];
  };

  flake.homeModules.kitty = {pkgs, ...}: let
    quietPluh = pkgs.runCommand "pluh-quiet.ogg" {nativeBuildInputs = [pkgs.ffmpeg];} ''
      ffmpeg -i ${../../assets/pluh.ogg} -af "volume=0.2" -c:a libvorbis $out
    '';
  in {
    programs.kitty = {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
        # enable_audio_bell = false;
        bell_path = "${quietPluh}";
      };
    };
  };
}
