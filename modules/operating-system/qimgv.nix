# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{...}: {
  flake.nixosModules.qimgv = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.qimgv
    ];
  };
}
