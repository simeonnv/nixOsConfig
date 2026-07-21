{...}: {
  flake.nixosModules.greeter = {
    pkgs,
    config,
    lib,
    ...
  }: {
    services.greetd.enable = true;

    services.greetd.settings = {
      default_session = {
        command = lib.concatStringsSep " " [
          "${pkgs.tuigreet}/bin/tuigreet"
          "--time"
          "--remember"
          "--remember-user-session"
          "--asterisks"
          "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
        ];
        user = "greeter";
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/cache/tuigreet 0755 greeter greeter - -"
    ];

    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };

    boot.consoleLogLevel = 3;
  };
}
