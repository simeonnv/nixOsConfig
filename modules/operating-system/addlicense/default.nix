# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{...}: {
  flake.nixosModules.addlicense = {pkgs, ...}: let
    license-sign = pkgs.writeShellApplication {
      name = "license-sign";
      runtimeInputs = with pkgs; [
        addlicense
        askalono
        git
        jq
        findutils
        coreutils
      ];
      text = builtins.readFile ./license-sign.sh;
    };
  in {
    environment.systemPackages = [
      pkgs.addlicense
      license-sign
    ];
  };
}
