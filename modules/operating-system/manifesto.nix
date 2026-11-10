# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{inputs, ...}: {
  flake.nixosModules.manifesto = {...}: {
    imports = [inputs.manifesto.nixosModules.default];

    services.manifesto = {
      enable = true;
      host = "127.0.0.1";
      port = 8080;
    };
  };
}
