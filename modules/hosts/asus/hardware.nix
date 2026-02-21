{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.asus = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      asus
    ];
  };

  flake.nixosModules.asus = {
    imports = [./_hardware-configuration.nix];
    boot.loader.grub.enable = true;
  };
}
