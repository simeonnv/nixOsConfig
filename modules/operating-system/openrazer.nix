# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{
  inputs,
  ownerProfile,
  ...
}: {
  flake.nixosModules.openrazer = {
    config,
    pkgs,
    lib,
    ...
  }: {
    hardware.openrazer.enable = true;
    hardware.openrazer.packages.kernel = config.boot.kernelPackages.openrazer.overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [pkgs.buildPackages.kmodigest];
      postFixup =
        (old.postFixup or "")
        + ''
          for f in $out/lib/modules/*/kernel/drivers/hid/*.ko; do
            kmodigest "$f"
          done
        '';
    });
    environment.systemPackages = with pkgs; [
      openrazer-daemon
      polychromatic
    ];
    users.users.${ownerProfile.name}.extraGroups = ["openrazer"];
  };
}
