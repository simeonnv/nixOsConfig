# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{
  flake.nixosModules.sudo-server = {
    security.sudo.extraRules = [
      {
        groups = ["wheel"];
        commands = [
          {
            command = "ALL";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];
  };
}
