# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT
{self, ...}: let
  niriVersion = "26.04";
  noctaliaVersion = "5.5.0";
  mkNiri = pkgs: pkgs-multiverse: let
    niri = pkgs-multiverse.version "niri" niriVersion;
  in
    pkgs.symlinkJoin {
      name = "niri-${niri.version}";
      inherit (niri) version meta passthru;
      paths = [niri];
      postBuild = ''
        rm $out/bin/niri-session
        substitute ${niri}/bin/niri-session $out/bin/niri-session \
          --replace-fail "systemctl --user import-environment" "systemctl --user import-environment 2>/dev/null"
        chmod +x $out/bin/niri-session
      '';
    };
in {
  flake.nixosModules.niri = {
    pkgs,
    pkgs-multiverse,
    ...
  }: {
    security.polkit.enable = true;
    services.upower.enable = true;

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    programs.niri = {
      enable = true;
      package = mkNiri pkgs pkgs-multiverse;
      useNautilus = false;
    };
  };

  flake.homeModules.niri = {
    pkgs,
    pkgs-multiverse,
    lib,
    config,
    ...
  }: let
    cfg = config.wm;
    colors = config.lib.stylix.colors.withHashtag;
    noctalia = "${lib.getExe config.programs.noctalia.package} msg";
    msg = cmd: {spawn-sh = "${noctalia} ${cmd}";};

    enabledBinds = lib.filterAttrs (_: b: b.enable) cfg.keybinds;

    niriAction = name: arg:
      {
        close-window = {close-window = {};};
        force-kill = {spawn-sh = "niri msg --json focused-window | ${pkgs.jq}/bin/jq '.pid // empty' | xargs -r kill -9";};
        fullscreen = {fullscreen-window = {};};
        toggle-floating = {toggle-window-floating = {};};
        reload-config = msg "config-reload";
        exit = {quit = {};};
        focus-left = {focus-column-left = {};};
        focus-right = {focus-column-right = {};};
        focus-up = {focus-window-or-workspace-up = {};};
        focus-down = {focus-window-or-workspace-down = {};};
        move-left = {move-column-left = {};};
        move-right = {move-column-right = {};};
        move-up = {move-window-up-or-to-workspace-up = {};};
        move-down = {move-window-down-or-to-workspace-down = {};};
        grow-width = {set-column-width = "+10%";};
        shrink-width = {set-column-width = "-10%";};
        grow-height = {set-window-height = "+10%";};
        shrink-height = {set-window-height = "-10%";};
        focus-workspace = {focus-workspace = toString arg;};
        move-to-workspace = {move-column-to-workspace = toString arg;};
        launcher = msg "panel-toggle launcher";
        clipboard = msg "panel-toggle clipboard";
        screenshot = msg "screenshot-region --annotate";
        lock = msg "session lock";
        show-keybinds = {spawn-sh = "${lib.getExe config.programs.noctalia.package} dmenu -p Keybinds < ${cfg.keybindsHelp}";};
        pointer-hint = {spawn-sh = "${cfg.wlKbptr}/bin/wl-kbptr -o modes=floating -o mode_floating.source=detect";};
        brightness-up = msg "brightness-up";
        brightness-down = msg "brightness-down";
        volume-up = msg "volume-up";
        volume-down = msg "volume-down";
        volume-mute = msg "volume-mute";
        dnd-toggle = msg "notification-dnd-toggle";
        media-toggle = msg "media toggle";
        media-next = msg "media next";
        media-previous = msg "media previous";
      }
      .${
        name
      };

    niriBody = b:
      if b.niri != null
      then b.niri
      else if b.action != null
      then niriAction b.action b.arg
      else if b.launch != null
      then {spawn-sh = b.launch;}
      else if b.exec != null
      then {spawn-sh = b.exec;}
      else null;

    binds =
      lib.filterAttrs (_: v: v != null)
      (lib.mapAttrs (_: b: let
        body = niriBody b;
      in
        if body == null
        then null
        else
          body
          // {
            _props =
              {hotkey-overlay-title = b.description;}
              // lib.optionalAttrs b.allowWhenLocked {allow-when-locked = true;};
          })
      enabledBinds);

    terminalSplit = pkgs.writeShellScript "niri-terminal" ''
      case "$(niri msg --json focused-window | ${pkgs.jq}/bin/jq -r '.app_id // empty')" in
        kitty|kitty-split)
          niri msg action set-column-width 50%
          exec kitty --class kitty-split
          ;;
        *)
          exec kitty
          ;;
      esac
    '';

    flags = attrs: lib.concatMapAttrs (name: cond: lib.optionalAttrs cond {${name} = {};}) attrs;
  in {
    imports = [self.homeModules.wm-common];

    home.packages = [pkgs.jq];

    wm.keybinds = {
      "Mod+Return".niri.spawn = ["${terminalSplit}"];
      "Mod+o" = {
        niri.toggle-overview = {};
        description = "overview";
      };
    };

    wayland.windowManager.niri = {
      enable = true;
      package = mkNiri pkgs pkgs-multiverse;
      systemd.enable = false;
      portalPackage = null;
      settings = {
        input = {
          keyboard = with cfg.input.keyboard; {
            xkb = {inherit layout options;};
            repeat-delay = repeatDelay;
            repeat-rate = repeatRate;
          };
          touchpad = with cfg.input.touchpad;
            flags {
              inherit tap dwt;
              natural-scroll = naturalScroll;
              middle-emulation = middleEmulation;
            }
            // {accel-profile = accelProfile;};
        };

        layout = {
          gaps = cfg.gaps.inner;
          struts = {
            left = cfg.gaps.outer;
            right = cfg.gaps.outer;
            top = cfg.gaps.outer;
            bottom = cfg.gaps.outer;
          };
          focus-ring = {
            width = 2;
            active-color = colors.base0D;
            inactive-color = colors.base03;
            urgent-color = colors.base08;
          };
          border.off = {};
          default-column-width.proportion = 1.0;
          preset-column-widths._children = map (proportion: {inherit proportion;}) [0.33333 0.5 0.66667 1.0];
        };

        cursor = {
          xcursor-theme = config.stylix.cursor.name;
          xcursor-size = config.stylix.cursor.size;
        };

        gestures.hot-corners.off = {};

        prefer-no-csd = {};
        hotkey-overlay.skip-at-startup = {};
        screenshot-path = "~/Pictures/Screenshots/screenshot-%Y%m%d-%H%M%S.png";
        debug.honor-xdg-activation-with-invalid-serial = {};

        inherit binds;

        _children =
          lib.mapAttrsToList (name: o: {
            output = {
              _args = [name];
              mode = "${o.mode}@${o.refresh}";
              inherit (o) scale;
              position._props = {inherit (o) x y;};
            };
          })
          cfg.outputs
          ++ map (n: {workspace._args = [(toString n)];}) (lib.range 1 10)
          ++ map (cmd: {spawn-sh-at-startup = cmd;}) cfg.startup
          ++ [
            {
              window-rule._children = [
                {match._props.app-id = "dev.noctalia.Noctalia";}
                {open-floating = true;}
              ];
            }
            {
              window-rule._children = [
                {match._props.app-id = "^kitty-split$";}
                {default-column-width.proportion = 0.5;}
              ];
            }
            {
              layer-rule._children = [
                {match._props.namespace = "^noctalia-";}
                {background-effect.blur = false;}
              ];
            }
          ];
      };
    };

    programs.noctalia = {
      enable = true;
      package = pkgs-multiverse.version "noctalia" noctaliaVersion;
      systemd.enable = true;
      settings = {
        shell = {
          launch_apps_as_systemd_services = true;
          polkit_agent = true;
        };
        audio = {
          enable_sounds = true;
          enable_notification_sounds = true;
          sound_theme = "papue";
        };
        wallpaper.default.path = "${config.stylix.image}";
        widget.wallpaper.enabled = false;
        widget.workspaces = {
          hide_when_empty = true;
          active_pill_size = 1.0;
        };
        bar.default = {
          thickness = 36;
          border = colors.base0D;
          border_width = 2;
          compositor_blur = false;
          radius = 0;
          radius_top_left = 0;
          radius_top_right = 0;
          radius_bottom_left = 0;
          radius_bottom_right = 0;
          concave_edge_corners = false;
          font_scale = 1.143;
          capsule_radius = 0;
          shadow = false;
          margin_ends = -2;
          margin_edge = -2;
        };
        shell.session.actions = [
          {
            action = "lock";
            shortcut = "1";
          }
          {
            action = "lock_and_suspend";
            shortcut = "2";
          }
        ];
        location.address = lib.mkDefault "Sofia, Bulgaria";
        idle.behavior = {
          lock = {
            enabled = true;
            action = "lock";
            timeout = 300;
          };
          screen-off = {
            enabled = true;
            action = "screen_off";
            timeout = 600;
          };
        };
      };
    };

    xdg.dataFile = {
      "sounds/papue/index.theme".text = ''
        [Sound Theme]
        Name=papue
        Inherits=freedesktop
        Directories=stereo

        [stereo]
        OutputProfile=stereo
      '';
      "sounds/papue/stereo/message-new-instant.oga".source = cfg.notificationSound;
    };

    systemd.user.services.noctalia = {
      Unit = {
        After = lib.mkForce ["niri.service"];
        Before = ["graphical-session.target"];
      };
      Service = {
        Type = "notify";
        ExecStartPre = "${pkgs.coreutils}/bin/rm -rf %S/noctalia/clipboard";
      };
      Install.WantedBy = lib.mkForce ["niri.service"];
    };
  };
}
