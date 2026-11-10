# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{...}: {
  flake.nixosModules.telegram = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [telegram-desktop];
  };
}
