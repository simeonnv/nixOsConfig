{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # sway
    swaybg
    swaylock
    swaysettings
    swayidle
    mako          # Notification daemon
    
    # Utilities
    kitty     # Terminal
    rofi          # Application launcher
    grim          # Screenshot tool
    slurp         # Select area for screenshot
    brightnessctl
    pavucontrol
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    QT_QPA_PLATFORM = "wayland";
  };
  
  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    systemd.enable = true;
    swaynag.enable = true;
    config = rec {
      modifier = "Mod4";
      terminal = "kitty"; 
      menu = "rofi";

      bars = [
        {
          command = "swaybar";
          position = "top";
        }
      ];

      input = {
        "type:keyboard" = {
          xkb_layout = "us";
        };
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
        };
      };

      keybindings = lib.mkOptionDefault {
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+q" = "kill";
        "Alt+t" = "exec ${menu} -show run";
        
        "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute"        = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };

      startup = [
        { command = "mako"; }
        { command = "wl-paste --type text --watch cliphist store"; }
        { command = "wl-paste --type image --watch cliphist store"; }
        { command = "wl-clip-persist --clipboard regular"; }
      ];
    };
    
    extraOptions = ["--unsupported-gpu"];
    extraSessionCommands = ''
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';
  };
}
