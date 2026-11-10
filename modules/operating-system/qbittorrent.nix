# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{pkgs, ...}: {
  flake.nixosModules.qbittorrent = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.qbittorrent
    ];
  };
}
