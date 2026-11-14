# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{inputs, ...}: {
  flake.nixosModules.metrolist = {pkgs, ...}: {
    environment.systemPackages = [
      inputs.metrolist.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
