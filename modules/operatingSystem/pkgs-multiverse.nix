{inputs, ...}: {
  flake.nixosModules.pkgs-multiverse = {pkgs, ...}: let
    pkgs-multiverse = inputs.nixpkgs-multiverse.lib.mkMultiverse {
      inherit (pkgs.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  in {
    _module.args.pkgs-multiverse = pkgs-multiverse;
    home-manager.sharedModules = [{_module.args.pkgs-multiverse = pkgs-multiverse;}];
  };
}
