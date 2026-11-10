# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{pkgs, ...}: {
  flake.nixosModules.file-roller = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.file-roller
    ];
  };
}
