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
    ];
  };

  flake.homeModules.sway = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = [
      pkgs.wofi
      pkgs.i3status
      pkgs.networkmanagerapplet
      pkgs.pulseaudio
    ];

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

    wayland.windowManager.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      config = rec {
        modifier = "Mod4";
        terminal = "kitty";
        startup = [
          # {command = "firefox";}
          {command = "nm-applet";}
        ];
        keybindings = lib.mkOptionDefault {
          "${modifier}+q" = "kill";
          "${modifier}+d" = "exec wofi --show drun";
          "Mod1+t" = "exec wofi --show drun";
          "${modifier}+Shift+r" = "reload";
          "${modifier}+f" = "fullscreen toggle";

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
          };
        };
      };
    };
  };
}
