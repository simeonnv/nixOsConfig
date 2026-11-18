# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{self, ...}: let
  swayVersion = "1.12";
in {
  flake.nixosModules.sway = {
    pkgs,
    pkgs-multiverse,
    ...
  }: {
    security.polkit.enable = true;

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    xdg.portal.wlr = {
      enable = true;
      settings.screencast = {
        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
        force_mod_linear = 1;
      };
    };

    programs.sway = {
      enable = true;
      package = pkgs-multiverse.version "sway" swayVersion;
      xwayland.enable = true;
      extraOptions = [
        "--unsupported-gpu"
      ];
      wrapperFeatures.gtk = true;
    };

    environment.systemPackages = with pkgs; [
      wl-clipboard
      adwaita-icon-theme
      hicolor-icon-theme
    ];
  };

  flake.homeModules.sway = {
    pkgs,
    pkgs-multiverse,
    lib,
    config,
    ...
  }: let
    cfg = config.wm;
    swayCfg = config.wayland.windowManager.sway;
    swaymsg = "${swayCfg.package}/bin/swaymsg";
    colors = config.lib.stylix.colors.withHashtag;
    stylixBar = config.stylix.targets.sway.exportedBarConfig;
    barButton = background: text: {
      inherit background text;
      border = background;
    };
    barConfig =
      stylixBar
      // {
        fonts = {
          names = ["IBM 3270"];
          size = 11.0;
        };
        colors =
          stylixBar.colors
          // {
            background = colors.base00;
            statusline = colors.base05;
            separator = colors.base03;
            focusedWorkspace = barButton colors.base0D colors.base00;
            activeWorkspace = barButton colors.base01 colors.base05;
            inactiveWorkspace = barButton colors.base01 colors.base05;
            urgentWorkspace = barButton colors.base08 colors.base00;
            bindingMode = barButton colors.base08 colors.base00;
          };
      };
    wl-kbptr = "${cfg.wlKbptr}/bin/wl-kbptr -o modes=floating -o mode_floating.source=detect";
    # i3status has no backlight module; inject a brightness block into its
    # i3bar JSON stream, right after the volume block
    run-scoped = pkgs.writeShellScript "run-scoped" ''
      exec ${pkgs.systemd}/bin/systemd-run --user --scope --slice=app.slice --collect --quiet \
        --unit="app-sway-$(${pkgs.systemd}/bin/systemd-escape "''${1##*/}")-$$" -- "$@"
    '';
    i3status-with-brightness = pkgs.writeShellScript "i3status-with-brightness" ''
      ${pkgs.i3status}/bin/i3status | {
        read -r header && printf '%s\n' "$header"
        read -r open && printf '%s\n' "$open"
        while read -r line; do
          prefix=""
          case "$line" in
            ,*) prefix=","; line=''${line#,} ;;
          esac
          pct=$(${pkgs.brightnessctl}/bin/brightnessctl -m | ${pkgs.coreutils}/bin/cut -d, -f4)
          printf '%s%s\n' "$prefix" "$(printf '%s' "$line" | ${pkgs.jq}/bin/jq -c --arg b "☀ $pct" \
            '(map(.name) | index("volume")) as $i
             | if $i == null then .
               else .[:$i + 1] + [{full_text: $b, name: "brightness"}] + .[$i + 1:]
               end')"
        done
      }
    '';

    enabledBinds = lib.filterAttrs (_: b: b.enable) cfg.keybinds;

    exec = name: cmd: "exec ${pkgs.writeShellScript "sway-${name}" cmd}";

    swayAction = name: arg:
      {
        close-window = "kill";
        force-kill = exec "force-kill" "${swaymsg} -t get_tree | ${pkgs.jq}/bin/jq '.. | select(.focused? == true) | select(.pid != null) | .pid' | xargs kill -9";
        fullscreen = "fullscreen toggle";
        toggle-floating = "floating toggle";
        reload-config = "reload";
        exit = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' '${swaymsg} exit'";
        focus-left = "focus left";
        focus-right = "focus right";
        focus-up = "focus up";
        focus-down = "focus down";
        move-left = "move left";
        move-right = "move right";
        move-up = "move up";
        move-down = "move down";
        grow-width = "resize grow width 10 px";
        shrink-width = "resize shrink width 10 px";
        grow-height = "resize grow height 10 px";
        shrink-height = "resize shrink height 10 px";
        focus-workspace = "workspace number ${toString arg}";
        move-to-workspace = "move container to workspace number ${toString arg}";
        launcher = "exec ${run-scoped} wofi --show drun";
        clipboard = exec "clipboard" "${pkgs.cliphist}/bin/cliphist list | wofi --dmenu | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy";
        screenshot = exec "screenshot" ''grim -g "$(slurp)" - | swappy -f -'';
        lock = "exec swaylock -f -c 000000";
        show-keybinds = exec "show-keybinds" "wofi --dmenu -p Keybinds < ${cfg.keybindsHelp}";
        pointer-hint = exec "pointer-hint" "${wl-kbptr}; ${swaymsg} mode mouse";
        brightness-up = "exec brightnessctl set +5%";
        brightness-down = "exec brightnessctl set 5%-";
        volume-up = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        volume-down = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
        volume-mute = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
        media-toggle = "exec ${lib.getExe pkgs.playerctl} play-pause";
        media-next = "exec ${lib.getExe pkgs.playerctl} next";
        media-previous = "exec ${lib.getExe pkgs.playerctl} previous";
        dnd-toggle = exec "dnd-toggle" ''
          ${pkgs.mako}/bin/makoctl mode -t do-not-disturb
          if ${pkgs.mako}/bin/makoctl mode | grep -q do-not-disturb; then
            ${pkgs.libnotify}/bin/notify-send -a dnd-toggle -t 2000 "Notifications off"
          else
            ${pkgs.libnotify}/bin/notify-send -a dnd-toggle -t 2000 "Notifications on"
          fi
        '';
      }
      .${name};

    swayCommand = key: b:
      if b.sway != null
      then b.sway
      else if b.action != null
      then swayAction b.action b.arg
      else if b.launch != null
      then "exec ${run-scoped} ${b.launch}"
      else if b.exec != null
      then exec (lib.strings.sanitizeDerivationName key) b.exec
      else null;

    swayKey = key:
      lib.optionalString (enabledBinds.${key}.allowWhenLocked) "--locked "
      + lib.concatMapStringsSep "+" (k:
        {
          Mod = swayCfg.config.modifier;
          Alt = "Mod1";
          Ctrl = "Control";
        }
        .${k}
        or k) (lib.splitString "+" key);

    onOff = b:
      if b
      then "enabled"
      else "disabled";
  in {
    imports = [self.homeModules.wm-common];

    home.packages = with pkgs; [
      wofi
      cliphist
      wl-clipboard
      i3status
      networkmanagerapplet
      pulseaudio
      brightnessctl

      grim
      slurp
      swappy

      wlrctl

      libappindicator-gtk3

      swaylock
      swayidle

      jq
    ];

    xdg.configFile."swappy/config".text = ''
      [Default]
      save_dir=$HOME/Pictures/Screenshots
      save_filename_format=screenshot-%Y%m%d-%H%M%S.png
    '';

    services.mako = {
      enable = true;
      settings.default-timeout = 5000;
      extraConfig = ''
        [mode=do-not-disturb]
        invisible=1

        [mode=do-not-disturb app-name=dnd-toggle]
        invisible=0
      '';
    };

    programs.i3status = {
      enable = true;
      general = {
        colors = true;
        color_good = colors.base0D;
        color_degraded = colors.base09;
        color_bad = colors.base08;
        interval = 5;
        output_format = "i3bar";
      };
      modules = {
        "volume master" = {
          position = 1;
          settings = {
            format = "♪ %volume";
            format_muted = "♪ muted (%volume)";
            device = "default";
          };
        };
        "wireless _first_" = {
          position = 2;
          settings = {
            format_up = "W: %essid %quality %ip";
            format_down = "W: down";
          };
        };
        "tztime local" = {
          position = 3;
          settings = {
            format = "TIME %Y-%m-%d %H:%M:%S";
          };
        };
        "cpu_usage" = {
          position = 8;
          settings = {
            format = "CPU %usage";
          };
        };
        "memory" = {
          position = 9;
          settings = {
            format = "RAM %used";
          };
        };
      };
    };

    programs.swaylock = {
      enable = true;
      settings = {
        indicator-idle-visible = true;
        show-failed-attempts = true;
      };
    };

    services.swayidle = {
      enable = true;
      systemdTargets = ["sway-session.target"];
      events = {
        before-sleep = "${pkgs.swaylock}/bin/swaylock -f -c 000000";
        lock = "${pkgs.swaylock}/bin/swaylock -f -c 000000";
      };
      timeouts = [
        {
          timeout = 300;
          command = "${pkgs.swaylock}/bin/swaylock -f -c 000000";
        }
        {
          timeout = 600;
          command = "${swaymsg} 'output * power off'";
          resumeCommand = "${swaymsg} 'output * power on'";
        }
      ];
    };

    services.udiskie = {
      enable = true;
      automount = true;
      notify = true;
      tray = "never";
      settings = {
        program_options.file_manager = "thunar";
        device_config = [
          {
            id_label = "keys";
            options = ["noatime" "compress=zstd"];
          }
        ];
      };
    };

    wayland.windowManager.sway = {
      enable = true;
      package = (pkgs-multiverse.version "sway" swayVersion).override {
        inherit (swayCfg) extraOptions extraSessionCommands;
        withBaseWrapper = swayCfg.wrapperFeatures.base;
        withGtkWrapper = swayCfg.wrapperFeatures.gtk;
      };
      wrapperFeatures.gtk = true;
      extraOptions = [
        "--unsupported-gpu"
      ];
      config = {
        modifier = "Mod4";
        terminal = "${run-scoped} kitty";
        gaps = {
          inherit (cfg.gaps) inner outer;
          smartGaps = true;
          smartBorders = "on";
        };
        startup =
          [
            {command = "nm-applet";}
            {command = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store";}
            {command = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store";}
          ]
          ++ map (command: {inherit command;}) cfg.startup;
        keybindings =
          lib.filterAttrs (_: v: v != null)
          (lib.mapAttrs' (key: b: lib.nameValuePair (swayKey key) (swayCommand key b)) enabledBinds);
        modes = lib.mkOptionDefault {
          mouse = {
            "f" = "exec ${pkgs.wlrctl}/bin/wlrctl pointer click left, mode \"default\"";
            "Shift+f" = "exec ${pkgs.wlrctl}/bin/wlrctl pointer click left";
            "r" = "exec ${pkgs.wlrctl}/bin/wlrctl pointer click right, mode \"default\"";
            "m" = "exec ${pkgs.wlrctl}/bin/wlrctl pointer click middle, mode \"default\"";

            "h" = "exec ${pkgs.wlrctl}/bin/wlrctl pointer move -15 0";
            "j" = "exec ${pkgs.wlrctl}/bin/wlrctl pointer move 0 15";
            "k" = "exec ${pkgs.wlrctl}/bin/wlrctl pointer move 0 -15";
            "l" = "exec ${pkgs.wlrctl}/bin/wlrctl pointer move 15 0";

            "d" = "exec ${pkgs.wlrctl}/bin/wlrctl pointer scroll 15 0";
            "u" = "exec ${pkgs.wlrctl}/bin/wlrctl pointer scroll -15 0";

            "apostrophe" = "mode \"default\", ${swayAction "pointer-hint" null}";

            "Escape" = "mode \"default\"";
            "Return" = "mode \"default\"";
          };
        };
        bars = [
          ({
              position = "top";
              statusCommand = "${i3status-with-brightness}";
              trayOutput = "*";
            }
            // barConfig)
        ];
        input = {
          "type:touchpad" = with cfg.input.touchpad; {
            dwt = onOff dwt;
            tap = onOff tap;
            natural_scroll = onOff naturalScroll;
            middle_emulation = onOff middleEmulation;
            accel_profile = accelProfile;
          };
          "type:keyboard" = with cfg.input.keyboard; {
            xkb_layout = layout;
            xkb_options = options;
            repeat_delay = toString repeatDelay;
            repeat_rate = toString repeatRate;
          };
        };
        output =
          lib.mapAttrs (_: o: {
            position = "${toString o.x} ${toString o.y}";
            mode = "${o.mode}@${o.refresh}Hz";
            scale = toString o.scale;
          })
          cfg.outputs;
      };
    };
  };
}
