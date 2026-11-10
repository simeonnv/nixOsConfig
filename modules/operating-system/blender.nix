# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{pkgs, ...}: {
  flake.nixosModules.blender = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.blender
    ];
  };
}
