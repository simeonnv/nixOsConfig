{
  lib,
  config,
  inputs,
  self,
  ownerProfile,
  flake-parts-lib,
  ...
}: let
  deployLibFor = system: let
    pkgs = inputs.nixpkgs.legacyPackages.${system};
    deployPkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [
        inputs.deploy-rs.overlays.default
        (final: prev: {
          deploy-rs = {
            inherit (pkgs) deploy-rs;
            inherit (prev.deploy-rs) lib;
          };
        })
      ];
    };
  in
    deployPkgs.deploy-rs.lib;
in {
  options.flake = flake-parts-lib.mkSubmoduleOptions {
    deploy = lib.mkOption {
      type = lib.types.submodule {
        freeformType = lib.types.lazyAttrsOf lib.types.raw;
        options.nodes = lib.mkOption {
          type = lib.types.lazyAttrsOf lib.types.raw;
          default = {};
          description = "deploy-rs nodes, one per host.";
        };
      };
      default = {};
      description = "deploy-rs configuration, read by `deploy .#<node>`.";
    };
  };

  config = {
    _module.args.deployLib = lib.genAttrs config.systems deployLibFor;

    flake.nixosModules.deploy-target = {
      nix.settings.trusted-users = [ownerProfile.name];
    };

    flake.deploy = {
      sshUser = "root";
      user = "root";
    };

    perSystem = {system, ...}: {
      checks = lib.mkIf (system == "x86_64-linux") (
        (deployLibFor system).deployChecks self.deploy
      );
    };
  };
}
