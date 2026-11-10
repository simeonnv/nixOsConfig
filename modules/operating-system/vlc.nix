# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{pkgs, ...}: {
  flake.nixosModules.vlc = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.vlc
    ];
  };
}
