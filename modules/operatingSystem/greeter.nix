{
  pkgs,
  inputs,
  ...
}: {
  flake.nixosModules.greeter = {
    pkgs,
    config,
    lib,
    options,
    ...
  }: let
    syscPackage = inputs.sysc-greet.packages.${pkgs.system}.default;
  in {
    imports = [
      inputs.sysc-greet.nixosModules.default
    ];

    users.users.greeter.extraGroups = ["video" "render" "input"];
    services.greetd.enable = true;
    environment.systemPackages = [
      pkgs.greetd
    ];

    services.sysc-greet = {
      enable = true;
      compositor = "sway";
    };

    services.greetd.settings = {
      default_session = {
        command = lib.mkForce "${syscPackage}/bin/sysc-greet";
        user = "greeter";
      };
    };
  };
}
