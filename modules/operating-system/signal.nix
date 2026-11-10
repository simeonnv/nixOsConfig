# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{
  flake.nixosModules.signal = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.signal-desktop
    ];
  };
}
