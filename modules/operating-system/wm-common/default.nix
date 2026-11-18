# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{...}: {
  flake.homeModules.wm-common = {
    lib,
    config,
    pkgs,
    osConfig ? {},
    ...
  }: let
    inherit (lib) mkOption types;

    actions = [
      "close-window"
      "force-kill"
      "fullscreen"
      "toggle-floating"
      "reload-config"
      "exit"
      "focus-left"
      "focus-right"
      "focus-up"
      "focus-down"
      "move-left"
      "move-right"
      "move-up"
      "move-down"
      "grow-width"
      "shrink-width"
      "grow-height"
      "shrink-height"
      "focus-workspace"
      "move-to-workspace"
      "launcher"
      "clipboard"
      "screenshot"
      "lock"
      "show-keybinds"
      "pointer-hint"
      "brightness-up"
      "brightness-down"
      "volume-up"
      "volume-down"
      "volume-mute"
      "dnd-toggle"
      "media-toggle"
      "media-next"
      "media-previous"
    ];

    bindType = types.submodule ({config, ...}: {
      options = {
        enable = mkOption {
          type = types.bool;
          default = true;
        };
        launch = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        exec = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        action = mkOption {
          type = types.nullOr (types.enum actions);
          default = null;
        };
        arg = mkOption {
          type = types.nullOr types.int;
          default = null;
        };
        sway = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        niri = mkOption {
          type = types.nullOr (types.attrsOf types.anything);
          default = null;
        };
        allowWhenLocked = mkOption {
          type = types.bool;
          default = false;
        };
        description = mkOption {
          type = types.str;
          default =
            if config.action != null
            then config.action + lib.optionalString (config.arg != null) " ${toString config.arg}"
            else if config.launch != null
            then config.launch
            else if config.exec != null
            then config.exec
            else "custom";
        };
      };
    });

    outputType = types.submodule {
      options = {
        mode = mkOption {type = types.str;};
        refresh = mkOption {type = types.str;};
        scale = mkOption {
          type = types.float;
          default = 1.0;
        };
        x = mkOption {
          type = types.int;
          default = 0;
        };
        y = mkOption {
          type = types.int;
          default = 0;
        };
      };
    };

    mkDefaults = lib.mapAttrs (_: lib.mapAttrs (_: lib.mkDefault));

    workspaceBinds = lib.listToAttrs (lib.concatMap (n: let
      key = toString (lib.mod n 10);
    in [
      (lib.nameValuePair "Mod+${key}" {
        action = "focus-workspace";
        arg = n;
      })
      (lib.nameValuePair "Mod+Shift+${key}" {
        action = "move-to-workspace";
        arg = n;
      })
    ]) (lib.range 1 10));

    directionBinds = lib.listToAttrs (lib.concatMap ({
      dir,
      keys,
      resize,
    }:
      [
        (lib.nameValuePair "Mod+Ctrl+${dir.vim}" {action = resize;})
      ]
      ++ lib.concatMap (key: [
        (lib.nameValuePair "Mod+${key}" {action = "focus-${dir.name}";})
        (lib.nameValuePair "Mod+Shift+${key}" {action = "move-${dir.name}";})
        (lib.nameValuePair "Mod+Ctrl+${key}" {action = resize;})
      ])
      keys) [
      {
        dir = {
          name = "left";
          vim = "h";
        };
        keys = ["Left"];
        resize = "shrink-width";
      }
      {
        dir = {
          name = "right";
          vim = "l";
        };
        keys = ["Right"];
        resize = "grow-width";
      }
      {
        dir = {
          name = "up";
          vim = "k";
        };
        keys = ["k" "Up"];
        resize = "shrink-height";
      }
      {
        dir = {
          name = "down";
          vim = "j";
        };
        keys = ["j" "Down"];
        resize = "grow-height";
      }
    ]);

    colors = config.lib.stylix.colors.withHashtag;
  in {
    key = "wm-common";

    options.wm = {
      keybinds = mkOption {
        type = types.attrsOf bindType;
        default = {};
      };

      startup = mkOption {
        type = types.listOf types.str;
        default = [];
      };

      gaps = {
        inner = mkOption {
          type = types.int;
          default = 5;
        };
        outer = mkOption {
          type = types.int;
          default = 5;
        };
      };

      input = {
        keyboard = {
          layout = mkOption {
            type = types.str;
            default = "eu,bg(phonetic)";
          };
          options = mkOption {
            type = types.str;
            default = "grp:alt_shift_toggle";
          };
          repeatDelay = mkOption {
            type = types.int;
            default = 250;
          };
          repeatRate = mkOption {
            type = types.int;
            default = 50;
          };
        };
        touchpad = {
          tap = mkOption {
            type = types.bool;
            default = true;
          };
          dwt = mkOption {
            type = types.bool;
            default = true;
          };
          naturalScroll = mkOption {
            type = types.bool;
            default = true;
          };
          middleEmulation = mkOption {
            type = types.bool;
            default = true;
          };
          accelProfile = mkOption {
            type = types.enum ["flat" "adaptive"];
            default = "flat";
          };
        };
      };

      outputs = mkOption {
        type = types.attrsOf outputType;
        default = {};
      };

      keybindsHelp = mkOption {
        type = types.package;
        readOnly = true;
        default = pkgs.writeText "keybinds" (lib.concatStringsSep "\n"
          (lib.mapAttrsToList (key: b: "${key}  ${b.description}")
            (lib.filterAttrs (_: b: b.enable) config.wm.keybinds)));
      };

      wlKbptr = mkOption {
        type = types.package;
        default =
          if osConfig.hardware.nvidia.enabled or false
          then
            pkgs.wl-kbptr.overrideAttrs (old: {
              patches =
                (old.patches or [])
                ++ [
                  (pkgs.fetchpatch {
                    url = "https://github.com/moverest/wl-kbptr/commit/549b2f6f22584316d4331129e5f6a0780500e70b.patch";
                    hash = "sha256-0LcBhXa+botAWGF2EqtbUr7k3F4jWHulOjcTfTdOv+0=";
                  })
                ];
            })
          else pkgs.wl-kbptr;
      };
    };

    config = {
      assertions =
        lib.mapAttrsToList (key: bind: {
          assertion = lib.count (x: x != null) [bind.launch bind.exec bind.action] <= 1;
          message = "wm.keybinds.\"${key}\": set at most one of launch, exec, action";
        })
        config.wm.keybinds;

      wm.outputs = mkDefaults {
        "eDP-1" = {
          mode = "1920x1080";
          refresh = "144";
        };
        "HDMI-A-1" = {
          mode = "1920x1080";
          refresh = "74.973";
          x = 1920;
        };
      };

      wm.keybinds = mkDefaults (workspaceBinds
        // directionBinds
        // {
          "Mod+Return".launch = "kitty";
          "Mod+e".launch = "thunar";
          "Mod+b".launch = lib.getExe config.programs.firefox.finalPackage;

          "Mod+d".action = "launcher";
          "Alt+t".action = "launcher";
          "Mod+v".action = "clipboard";
          "Mod+Shift+s".action = "screenshot";
          "Mod+l".action = "lock";
          "Mod+h".action = "show-keybinds";
          "Mod+n".action = "dnd-toggle";

          "Mod+q".action = "close-window";
          "Mod+Shift+q".action = "force-kill";
          "Mod+f".action = "fullscreen";
          "Mod+space".action = "toggle-floating";
          "Mod+Shift+space".action = "toggle-floating";
          "Mod+Shift+r".action = "reload-config";
          "Mod+Shift+c".action = "reload-config";
          "Mod+Shift+e".action = "exit";

          "Mod+Shift+h".action = "move-left";
          "Mod+Shift+l".action = "move-right";

          "Mod+apostrophe".action = "pointer-hint";
          "Mod+Shift+apostrophe" = {
            sway = ''mode "mouse"'';
            description = "mouse mode";
          };

          "Mod+a" = {
            sway = "focus parent";
            description = "focus parent";
          };
          "Mod+s" = {
            sway = "layout stacking";
            description = "layout stacking";
          };
          "Mod+w" = {
            sway = "layout tabbed";
            niri.toggle-column-tabbed-display = {};
            description = "tabbed layout";
          };
          "Mod+r" = {
            sway = ''mode "resize"'';
            niri.switch-preset-column-width = {};
            description = "resize";
          };
          "Mod+Shift+f" = {
            niri.maximize-column = {};
            description = "maximize";
          };
          "Mod+Shift+minus" = {
            sway = "move scratchpad";
            description = "move to scratchpad";
          };

          "XF86MonBrightnessUp" = {
            action = "brightness-up";
            allowWhenLocked = true;
          };
          "XF86MonBrightnessDown" = {
            action = "brightness-down";
            allowWhenLocked = true;
          };
          "Mod+bracketright".action = "brightness-up";
          "Mod+bracketleft".action = "brightness-down";

          "Mod+equal".action = "volume-up";
          "Mod+minus".action = "volume-down";
          "Mod+m".action = "volume-mute";

          "Mod+Alt+Down".action = "media-toggle";
          "Mod+Alt+Right".action = "media-next";
          "Mod+Alt+Left".action = "media-previous";
          "XF86AudioPlay" = {
            action = "media-toggle";
            allowWhenLocked = true;
          };
          "XF86AudioNext" = {
            action = "media-next";
            allowWhenLocked = true;
          };
          "XF86AudioPrev" = {
            action = "media-previous";
            allowWhenLocked = true;
          };
        });

      home.packages = [config.wm.wlKbptr];

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
    };
  };
}
