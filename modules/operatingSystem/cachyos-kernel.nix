{inputs, ...}: {
  flake.nixosModules.cachyos-kernel = {pkgs, ...}: let
    kernel = pkgs.cachyosKernels.linux-cachyos-latest.override {
      pname = "linux";

      lto = "full";
      processorOpt = "native";
    };
  in {
    nixpkgs.overlays = [
      inputs.nix-cachyos-kernel.overlays.pinned
    ];

    boot.kernelPackages = pkgs.linuxKernel.packagesFor kernel;
    boot.kernelParams = ["pcie_aspm=off"];
  };
}
