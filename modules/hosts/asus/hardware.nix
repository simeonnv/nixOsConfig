{ inputs, ... }: {
  flake.nixosModules.asus = {
    imports = [ ./_hardware-configuration.nix ];
  };
}
