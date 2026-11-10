# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{pkgs, ...}: {
  flake.homeModules.eza = {...}: {
    programs.eza = {
      enable = true;
    };
  };
}
