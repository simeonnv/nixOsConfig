{inputs, ...}: {
  # Makes `pkgs-stable` available as a module argument to every NixOS module
  # (and every home-manager module) of any host that imports this.
  flake.nixosModules.pkgs-stable = {pkgs, ...}: let
    pkgs-stable = import inputs.nixpkgs-stable {
      inherit (pkgs.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  in {
    _module.args.pkgs-stable = pkgs-stable;
    home-manager.sharedModules = [{_module.args.pkgs-stable = pkgs-stable;}];
  };
}
