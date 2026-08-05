{pkgs, ...}: {
  flake.nixosModules.sway = {pkgs, ...}: {
    security.polkit.enable = true;

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    nixpkgs.overlays = [
      (final: prev: {
        xdg-desktop-portal-wlr = prev.xdg-desktop-portal-wlr.overrideAttrs (old: {
          patches = (old.patches or []) ++ [./xdpw-pr389-screencast-retry.patch];
        });
      })
    ];

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
    lib,
    config,
    ...
  }: let
    colors = config.lib.stylix.colors.withHashtag;
  in {
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

      wl-kbptr
      wlrctl

      libappindicator-gtk3

      swaylock
      swayidle

      jq
    ];

    xdg.configFile."wl-kbptr/config".text = ''
      [mode_floating]
      source=detect
      label_color=${colors.base05}
      label_select_color=${colors.base09}
      selectable_bg_color=${colors.base00}cc
      selectable_border_color=${colors.base0D}
      unselectable_bg_color=${colors.base00}80
      label_font_size=16 60% 120
    '';

    xdg.configFile."swappy/config".text = ''
      [Default]
      save_dir=$HOME/Pictures/Screenshots
      save_filename_format=screenshot-%Y%m%d-%H%M%S.png
    '';

    services.mako = {
      enable = true;
      defaultTimeout = 5000;
    };

    programs.i3status = {
      enable = true;
      general = {
        colors = true;
        interval = 5;
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
            format = "%Y-%m-%d %H:%M:%S";
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
      events = [
        {
          event = "before-sleep";
          command = "${pkgs.swaylock}/bin/swaylock -f -c 000000";
        }
        {
          event = "lock";
          command = "${pkgs.swaylock}/bin/swaylock -f -c 000000";
        }
      ];
      timeouts = [
        {
          timeout = 300;
          command = "${pkgs.swaylock}/bin/swaylock -f -c 000000";
        }
        {
          timeout = 600;
          command = "${pkgs.sway}/bin/swaymsg 'output * power off'";
          resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * power on'";
        }
      ];
    };

    wayland.windowManager.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraOptions = [
        "--unsupported-gpu"
      ];
      config = rec {
        modifier = "Mod4";
        terminal = "kitty";
        gaps = {
          inner = 5;
          outer = 5;
          smartGaps = true;
          smartBorders = "on";
        };
        startup = [
          {command = "nm-applet";}
          {command = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store";}
          {command = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store";}
        ];
        keybindings = lib.mkOptionDefault {
          "${modifier}+q" = "kill";
          "${modifier}+e" = "exec thunar";
          "${modifier}+b" = "exec firefox";
          "Mod1+t" = "exec wofi --show drun";
          "${modifier}+Shift+r" = "reload";
          "${modifier}+f" = "fullscreen toggle";

          "${modifier}+Shift+s" = "exec grim -g \"$(slurp)\" - | swappy -f -";

          "${modifier}+space" = "floating toggle";

          "${modifier}+v" = "exec ${pkgs.cliphist}/bin/cliphist list | wofi --dmenu | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy";

          "${modifier}+l" = "exec swaylock -f -c 000000";

          "${modifier}+h" = "exec swaymsg -t get_config | ${pkgs.jq}/bin/jq -r '.config' | grep -E '^[[:space:]]*bindsym' | sed -E 's/^[[:space:]]*bindsym //' | wofi --dmenu -p 'Keybinds'";

          # must NOT be in mouse mode while the overlay is up: sway binds (f/h/j/k/l...)
          # take precedence over the overlay and eat the label keys
          "${modifier}+apostrophe" = "exec '${pkgs.wl-kbptr}/bin/wl-kbptr -o modes=floating -o mode_floating.source=detect; swaymsg mode mouse'";
          "${modifier}+Shift+apostrophe" = "mode \"mouse\"";

          "${modifier}+Shift+q" = "exec swaymsg -t get_tree | ${pkgs.jq}/bin/jq '.. | select(.focused? == true) | select(.pid != null) | .pid' | xargs kill -9";

          "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
          "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
          "${modifier}+bracketright" = "exec brightnessctl set +5%";
          "${modifier}+bracketleft" = "exec brightnessctl set 5%-";

          "${modifier}+equal" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
          "${modifier}+minus" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
          "${modifier}+m" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
        };
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

            "apostrophe" = "mode \"default\", exec '${pkgs.wl-kbptr}/bin/wl-kbptr -o modes=floating -o mode_floating.source=detect; swaymsg mode mouse'";

            "Escape" = "mode \"default\"";
            "Return" = "mode \"default\"";
          };
        };
        bars = [
          {
            position = "top";
            statusCommand = "${pkgs.i3status}/bin/i3status";
            trayOutput = "*";
          }
        ];
        input = {
          "type:touchpad" = {
            dwt = "enabled";
            tap = "enabled";
            natural_scroll = "enabled";
            middle_emulation = "enabled";
            accel_profile = "flat";
          };
          "type:keyboard" = {
            xkb_layout = "eu,bg(phonetic)";
            xkb_options = "grp:alt_shift_toggle";
            repeat_delay = "250";
            repeat_rate = "50";
          };
        };
        output = {
          "eDP-1" = {
            position = "0 0";
            mode = "1920x1080@144Hz";
          };

          "HDMI-A-1" = {
            position = "1920 0";
            mode = "1920x1080@74.973Hz";
          };
        };
      };
    };
  };
}
