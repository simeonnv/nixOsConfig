# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{...}: {
  flake.nixosModules.manix = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.manix
    ];
  };
}
