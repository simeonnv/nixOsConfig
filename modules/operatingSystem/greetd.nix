{pkgs, ...}: {
  flake.nixosModules.greetd = {pkgs, ...}: {
    users.users.greeter.extraGroups = ["video" "render" "input"];
    services.greetd.enable = true;
    environment.systemPackages = [
      pkgs.greetd
    ];
  };
}
