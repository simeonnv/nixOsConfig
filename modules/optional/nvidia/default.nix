{ config, pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    # enabled = true;
    open = false;

    modesetting.enable = true;
    nvidiaSettings = true;
    powerManagement.enable = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  
}
