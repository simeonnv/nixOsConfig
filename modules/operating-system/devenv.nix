# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{pkgs, ...}: {
  flake.nixosModules.devenv = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.devenv
    ];
  };
}
