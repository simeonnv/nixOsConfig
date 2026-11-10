# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{pkgs, ...}: {
  flake.nixosModules.jujutsu = {
    lib,
    pkgs,
    ...
  }: {
    environment.systemPackages = with pkgs; [jujutsu lazyjj jjui];
  };

  flake.homeModules.jujutsu = {
    lib,
    pkgs,
    ...
  }: {
    programs = {
      jujutsu = {
        enable = true;
        userName = "simeon";
        userEmail = "simmeon.nv@proton.me";
      };
    };
  };
}
