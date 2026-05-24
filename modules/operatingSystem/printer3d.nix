{pkgs, ...}: {
  flake.nixosModules.printer3d = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      prusa-slicer
      octoprint
      cura-appimage
    ];

    boot.kernelModules = ["ch341"];
  };
}
