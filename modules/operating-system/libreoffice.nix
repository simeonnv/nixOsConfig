# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{
  pkgs,
  ownerProfile,
  ...
}: {
  flake.nixosModules.libreoffice = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      libreoffice
    ];
  };
}
