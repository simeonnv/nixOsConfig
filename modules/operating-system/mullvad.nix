{
  flake.nixosModules.mullvad = {
    pkgs,
    config,
    ...
  }: let
    mullvadCli = "${config.services.mullvad-vpn.package}/bin/mullvad";
  in {
    services.mullvad-vpn = {
      enable = true;
      enableEarlyBootBlocking = true;
      gui.enable = true;
    };

    systemd.services.mullvad-auto-connect = {
      after = ["mullvad-daemon.service"];
      requires = ["mullvad-daemon.service"];
      wantedBy = ["multi-user.target"];
      path = [pkgs.coreutils];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        for _ in $(seq 1 60); do
          ${mullvadCli} status >/dev/null 2>&1 && break
          sleep 1
        done
        ${mullvadCli} auto-connect set on
        ${mullvadCli} connect
      '';
    };
  };
}
