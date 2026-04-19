{pkgs, ...}: {
  flake.nixosModules.sway = {pkgs, ...}: {
    security.polkit.enable = true;
    programs.sway = {
      enable = true;
      xwayland.enable = true;
      extraOptions = [
        "--unsupported-gpu"
      ];
      wrapperFeatures.gtk = true;
    };

    environment.systemPackages = with pkgs; [
      sway
      wl-clipboard
      adwaita-icon-theme
      hicolor-icon-theme
    ];
  };

  flake.homeModules.sway = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = with pkgs; [
      wofi
      i3status
      networkmanagerapplet
      pulseaudio
      brightnessctl

      grim
      slurp
      swappy

      libappindicator-gtk3

      swaylock
      swayidle

      jq
    ];

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

          "${modifier}+l" = "exec swaylock -f -c 000000";

          "${modifier}+Shift+q" = "exec swaymsg -t get_tree | ${pkgs.jq}/bin/jq '.. | select(.focused? == true) | select(.pid != null) | .pid' | xargs kill -9";

          "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
          "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";

          "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
          "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
          "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
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
