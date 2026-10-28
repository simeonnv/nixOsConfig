{
  flake.nixosModules.memory = {
    systemd.oomd = {
      enable = true;
      enableRootSlice = true;
      enableSystemSlice = true;
      enableUserSlices = true;
      settings.OOM = {
        DefaultMemoryPressureDurationSec = "10s";
        SwapUsedLimit = "90%";
      };
    };

    systemd.slices.user.sliceConfig = {
      ManagedOOMMemoryPressureLimit = "50%";
      MemoryMin = "512M";
    };

    systemd.units."user-.slice" = {
      overrideStrategy = "asDropin";
      text = ''
        [Slice]
        MemoryMin=512M
      '';
    };

    systemd.units."session-.scope" = {
      overrideStrategy = "asDropin";
      text = ''
        [Scope]
        MemoryMin=512M
        ManagedOOMPreference=omit
      '';
    };

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
      priority = 100;
    };

    boot.kernelParams = ["zswap.enabled=0"];

    boot.kernel.sysctl = {
      "kernel.sysrq" = 1;
      "vm.swappiness" = 180;
      "vm.page-cluster" = 0;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
    };
  };
}
