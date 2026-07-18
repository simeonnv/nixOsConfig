{inputs, ...}: {
  flake.nixosModules.ai-slop = {
    pkgs,
    lib,
    ...
  }: {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) ["claude"];
    nixpkgs.overlays = [inputs.nix-claude-code.overlays.default];
    environment.systemPackages = [
      pkgs.claude-code
    ];
  };
}
