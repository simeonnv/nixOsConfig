# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{inputs, ...}: {
  flake.nixosModules.atopile = {pkgs, ...}: {
    nixpkgs.overlays = [inputs.nix-atopile.overlays.default];
    environment.systemPackages = [
      pkgs.atopile
    ];
  };
}
