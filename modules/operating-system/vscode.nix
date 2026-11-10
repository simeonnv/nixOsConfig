# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{pkgs, ...}: {
  flake.nixosModules.vscode = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.vscode
    ];
  };
}
