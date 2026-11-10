# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{
  flake.nixosModules.obs-studio = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.obs-studio
    ];
  };
}
