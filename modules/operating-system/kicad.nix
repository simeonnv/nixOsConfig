# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{pkgs, ...}: {
  flake.nixosModules.kicad = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.kicad
    ];
  };
}
