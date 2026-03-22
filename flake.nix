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

    sysc-greet = {
      url = "github:Nomadcxx/sysc-greet";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko.url = "github:nix-community/disko";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    manix.url = "github:mlvzk/manix";
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

      _module.args = {
        ownerProfile = ownerProfile;
      };
    };
}
