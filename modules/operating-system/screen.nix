# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{pkgs, ...}: {
  flake.nixosModules.screen = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.screen
    ];
  };
}
