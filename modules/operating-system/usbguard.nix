{
  flake.nixosModules.usbguard = {
    pkgs,
    lib,
    ...
  }: let
    usbguard-prompt = pkgs.writers.writePython3Bin "usbguard-prompt" {
      libraries = [pkgs.python3Packages.pygobject3];
      flakeIgnore = ["E402" "E501"];
    } (builtins.readFile ./usbguard-prompt.py);
  in {
    services.usbguard = {
      enable = true;
      dbus.enable = true;
      IPCAllowedUsers = ["root"];
      IPCAllowedGroups = [];
      implicitPolicyTarget = "block";
      presentDevicePolicy = "apply-policy";
      insertedDevicePolicy = "apply-policy";
      rules = ''
        allow with-interface match-all { 09:*:* }
        allow with-interface match-all { 11:*:* }
      '';
    };

    security.polkit.enable = true;

    systemd.user.services.hyprpolkitagent = {
      description = "Hyprland Polkit Authentication Agent";
      partOf = ["graphical-session.target"];
      after = ["graphical-session.target"];
      wantedBy = ["graphical-session.target"];
      unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
      serviceConfig = {
        ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
        Slice = "session.slice";
        Restart = "on-failure";
        TimeoutStopSec = "5sec";
      };
    };

    systemd.user.services.usbguard-prompt = {
      description = "Ask for authentication before allowing blocked USB devices";
      partOf = ["graphical-session.target"];
      after = ["graphical-session.target" "hyprpolkitagent.service"];
      wants = ["hyprpolkitagent.service"];
      wantedBy = ["graphical-session.target"];
      environment.GI_TYPELIB_PATH = lib.makeSearchPath "lib/girepository-1.0" [pkgs.glib.out];
      serviceConfig = {
        ExecStart = lib.getExe usbguard-prompt;
        Restart = "always";
        RestartSec = 5;
      };
    };
  };
}
