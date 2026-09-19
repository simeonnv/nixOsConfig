{
  pkgs,
  ownerProfile,
  ...
}: {
  flake.nixosModules.nvidia = {pkgs, ...}: {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    boot.kernelParams = ["nvidia-drm.modeset=1"];
    services.xserver.videoDrivers = ["nvidia"];
    hardware.nvidia.open = false;
  };
}
