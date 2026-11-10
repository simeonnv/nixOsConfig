# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{pkgs, ...}: {
  flake.nixosModules.minecraft = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.prismlauncher
    ];
  };
}
