# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{pkgs, ...}: {
  flake.nixosModules.dbeaver = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.dbeaver-bin
    ];
  };
}
