# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{
  flake.nixosModules.viber = {pkgs-multiverse, ...}: {
    environment.systemPackages = [
      (pkgs-multiverse.version "viber" "27.3.0.2")
    ];
  };
}
