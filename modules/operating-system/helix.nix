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

    steelixGrammarsJson = ./helix/grammars.json;
    steelixGrammars = lib.importJSON steelixGrammarsJson;
    steelixSrc = pkgs.steelix.unwrapped.src;

    grammarsCheck =
      pkgs.runCommand "steelix-grammars-check" {
        nativeBuildInputs = [pkgs.remarshal pkgs.jq];
      } ''
        toml2json ${steelixSrc}/languages.toml \
          | jq -r '.grammar[] | select(.source.git? and .source.rev?) | "\(.name | gsub("_"; "-")) \(.source.rev)"' \
          | sort > want
        jq -r 'to_entries[] | "\(.key) \(.value.nurl.args.rev)"' ${steelixGrammarsJson} | sort > have
        if ! diff -u want have; then
          echo "modules/operating-system/helix/grammars.json is out of sync with steelix ${steelixSrc.rev}." >&2
          echo "Regenerate it (see comment in modules/operating-system/helix.nix)." >&2
          exit 1
        fi
        touch $out
      '';

    tolerantGrammarsOverlay = _: prev:
      lib.mapAttrs (_: drv:
        if lib.isDerivation drv
        then
          drv.overrideAttrs (old:
            lib.optionalAttrs (lib.hasInfix "tree-sitter.json" (old.postPatch or "")) {
              postPatch = ''
                if [[ -e tree-sitter.json ]]; then
                ${old.postPatch}
                fi
              '';
            })
        else drv)
      prev;

    extraGrammarsOverlay = _: _: {
      tree-sitter-robots = let
        g = steelixGrammars.robots;
      in
        (pkgs.tree-sitter-grammars.tree-sitter-robots-txt.override {language = "robots";}).overrideAttrs {
          version = lib.sources.shortRev g.nurl.args.rev;
          src = pkgs.${g.nurl.fetcher} g.nurl.args;
        };
    };

    steelix =
      (pkgs.steelix.override {
        helix =
          pkgs.helix
          // {
            override = args:
              pkgs.helix.override (args
                // {
                  lockedGrammars = steelixGrammars;
                  grammarsOverlay = lib.composeManyExtensions [
                    (args.grammarsOverlay or (_: _: {}))
                    tolerantGrammarsOverlay
                    extraGrammarsOverlay
                  ];
                });
          };
      }).overrideAttrs {
        # depend on the check so a stale lockfile fails the build instead of going gray
        inherit grammarsCheck;
      };
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

      package = steelix;

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
