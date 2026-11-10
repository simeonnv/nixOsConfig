# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{pkgs, ...}: {
  flake.homeModules.btop = {...}: {
    programs.btop = {
      enable = true;
    };
  };
}
