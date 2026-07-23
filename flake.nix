{
  nixConfig = {
    extra-experimental-features = ["pipe-operators"];
  };

  inputs.self.submodules = true;
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";
    input-branches.url = "github:mightyiam/input-branches";

    disko.url = "github:nix-community/disko";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";

    # driver stack (open-fprintd + python-validity) for the ThinkPad T480's 06cb:009a
    # fingerprint sensor; keeps its own nixpkgs pin, only tested against 24.11
    nixos-06cb-009a-fingerprint-sensor.url = "github:ahbnr/nixos-06cb-009a-fingerprint-sensor?ref=24.11";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    manix.url = "github:mlvzk/manix";

    nix-claude-code.url = "github:ryoppippi/nix-claude-code";

    nixcord.url = "github:4evy/nixcord";

    concord.url = "github:chojs23/concord";
  };

  outputs = inputs: let
    ownerProfile = {
      name = "simeon";
      email = "simmeon.nv@proton.me";
    };
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        (inputs.import-tree ./modules)
        inputs.home-manager.flakeModules.home-manager
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem = {system, ...}: {
        _module.args.pkgs-stable = import inputs.nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
      };

      _module.args = {
        ownerProfile = ownerProfile;
      };
    };
}
