# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{inputs, ...}: {
  flake.nixosModules.metrolist = {pkgs, ...}: {
    environment.systemPackages = [
      (inputs.metrolist.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
        appimageTools =
          pkgs.appimageTools
          // {
            wrapType2 = args:
              pkgs.appimageTools.wrapType2 (args
                // {
                  extraBwrapArgs = (args.extraBwrapArgs or []) ++ ["--ro-bind-try" "/etc/alsa" "/etc/alsa"];
                });
          };
      })
    ];

    services.gnome.gnome-keyring.enable = true;
    services.gnome.glib-networking.enable = true;
  };
}
