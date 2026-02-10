{
  inputs.self.submodules = true;
  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    
    home-manager = {
      url = "./inputs/home-manager";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    import-tree.url = "github:vic/import-tree";
    input-branches.url = "github:mightyiam/input-branches";    
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; }
      (inputs.import-tree ./modules);
}
