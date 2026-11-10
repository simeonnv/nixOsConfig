# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{pkgs, ...}: {
  flake.homeModules.yazi = {pkgs, ...}: {
    programs.yazi = {
      enable = true;
      shellWrapperName = "yy";
    };
  };
}
