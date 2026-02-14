{ config, ... }:
{
  configurations.nixos.asus.module = {
    networking.hostName = "asus";
    networking.domain = "local";
    networking.hostId = "c53bf8an";
    system.stateVersion = "25.11";

    imports = with config.flake.modules.nixos; [
      pc
    ];
  };
}
