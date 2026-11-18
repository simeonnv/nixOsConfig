# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{...}: {
  flake.nixosModules.power-auth = {
    security.polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (/^org\.freedesktop\.login1\.(power-off|reboot|halt)/.test(action.id)) {
            return polkit.Result.AUTH_ADMIN;
          }
        });
      '';
    };
  };
}
