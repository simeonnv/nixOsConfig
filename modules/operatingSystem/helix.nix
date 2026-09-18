{inputs, ...}: {
  flake.homeModules.helix = {
    config,
    lib,
    pkgs,
    ...
  }: let
    hasStylixTheme = config.programs.helix.themes ? stylix;
    stylixColors = config.lib.stylix.colors.withHashtag or null;

    helixPlugins = config.programs.nhx.availablePlugins;

    presence = helixPlugins.callPackage ./helix/_presence.nix {};

    forest = helixPlugins.forest.overrideAttrs (old: {
      patches = (old.patches or []) ++ [./helix/forest-separator.patch];
    });

    helix-file-watcher = helixPlugins.helix-file-watcher.overrideAttrs (old: {
      meta = old.meta // {license = lib.licenses.mit;};
    });
  in {
    imports = [inputs.nhx.homeManagerModules.default];

    programs.helix.enable = false;

    home.sessionVariables.EDITOR = "hx";
    home.packages = with pkgs; [
      steel
      nixd
      alejandra
      rust-analyzer
      omnisharp-roslyn
      netcoredbg
      taplo
      yazi
      ty
    ];

    xdg.configFile = {
      "helix/themes/stylix.toml" = lib.mkIf hasStylixTheme {
        source = config.programs.helix.themes.stylix;
      };

      "helix/helix.scm".source = ./helix/helix.scm;
    };

    programs.nhx = {
      enable = true;

      steel = {
        enable = true;
        lsp.enable = true;
      };

      plugins = {
        helix-file-watcher = {
          enable = true;
          package = helix-file-watcher;
          requirePath = "helix-file-watcher/file-watcher.scm";
          extra = "(spawn-watcher 500)";
        };
        scooter.enable = true;
        forest = {
          enable = true;
          package = forest;
          config = {
            position = "right";
            ignore = [".git" "target" ".direnv" "result"];
            circularKeybinds = true;
            sidebarBg = lib.mkIf (stylixColors != null) {
              focused = stylixColors.base00;
              unfocused = stylixColors.base01;
            };
            searchColor = lib.mkIf (stylixColors != null) {
              focused = stylixColors.base0D;
              unfocused = stylixColors.base03;
              followFocus = true;
            };
          };
          extra =
            ''
              (forest-set-keybinds! (hash 'search "/"
                                          'refresh "R"))
              (forest-set-gap! 1)
            ''
            + lib.optionalString (stylixColors != null) ''
              (forest-set-separator-color! "${stylixColors.base0D}") ; accent / iris on rose-pine
            '';
        };
        helix-discord-rpc = {
          enable = true;
          package = presence;
          extra = "(discord-rpc-connect)";
        };
      };

      settings = {
        theme = lib.mkIf hasStylixTheme "stylix";
        editor = {
          lsp = {
            display-messages = true;
            display-inlay-hints = true;
            display-progress-messages = true;
          };
          auto-save = {
            focus-lost = true;
            after-delay.enable = true;
          };
          soft-wrap.enable = true;
          inline-diagnostics = {
            cursor-line = "hint";
            # other-lines = "error";
          };
          completion-replace = true;
        };
        keys.normal = {
          space.e = ":forest-open";
          space.E = "file_explorer_in_current_buffer_directory";
        };
      };

      languages = {
        language-server.rust-analyzer.config = {
          assist = {
            preferSelf = true;
          };
          check = {
            command = "clippy";
          };
          inlayHints = {
            closureCaptureHints.enable = true;
            # lifetimeElisionHints.enable = "always";
            # lifetimeElisionHints.useParameterNames = true;
            implicitDrops.enable = true;
            # genericParameterHints.lifetime.enable = true;
            genericParameterHints.type.enable = true;
            # reborrowHints.enable = "always";
          };
        };
        language = [
          {
            name = "nix";
            auto-format = true;
            formatter = {
              command = "${pkgs.alejandra}/bin/alejandra";
            };
          }
          {
            name = "rust";
            auto-format = true;
            language-servers = ["rust-analyzer"];
          }
        ];
      };
    };
  };
}
