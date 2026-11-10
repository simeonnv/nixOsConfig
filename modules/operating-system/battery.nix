# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{
  flake.homeModules.battery = {
    services.batsignal = {
      enable = true;
      extraArgs = ["-w" "20" "-c" "10" "-d" "5"];
    };
  };
}
