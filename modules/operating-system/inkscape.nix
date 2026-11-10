# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{...}: {
  flake.nixosModules.inkscape = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.inkscape-with-extensions
    ];
  };
}
