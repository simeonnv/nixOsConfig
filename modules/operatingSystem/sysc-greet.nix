{
  pkgs,
  inputs,
  ...
}: {
  flake.nixosModules.sysc-greet = {pkgs, ...}: {
    imports = [
      inputs.sysc-greet.nixosModules.default
    ];
    services.sysc-greet = {
      enable = true;
      compositor = "sway";
    };
  };
}
