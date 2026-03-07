{pkgs, ...}: {
  flake.nixosModules.greetd = {
    pkgs,
    config,
    lib,
    options,
    ...
  }: let
    syscGreetEnabled = (options.services ? sysc-greet) && config.services.sysc-greet.enable;
  in {
    users.users.greeter.extraGroups = ["video" "render" "input"];
    services.greetd.enable = true;
    environment.systemPackages = [
      pkgs.greetd
    ];

    services.greetd.settings = lib.mkIf syscGreetEnabled {
      default_session = {
        command = "${pkgs.sysc-greet}/bin/sysc-greet";
        user = "greeter";
      };
    };
  };
}
