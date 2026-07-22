{
  flake.nixosModules.printer3d = {
    pkgs,
    pkgs-stable,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      prusa-slicer
      # unstable's setuptools 82 removed pkg_resources, which octoprint's
      # bundled plugins still import at build time; take octoprint from
      # stable until upstream fixes it
      pkgs-stable.octoprint
      cura-appimage
    ];

    boot.kernelModules = ["ch341"];
  };
}
