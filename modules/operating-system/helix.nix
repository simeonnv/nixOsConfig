{
  flake.homeModules.helix = {pkgs, ...}: {
    home.packages = with pkgs; [
      nixd
      alejandra
      rust-analyzer
      omnisharp-roslyn
      netcoredbg
      taplo
      yazi
      ty
      harper
    ];

    xdg.configFile = builtins.listToAttrs (map (q: {
      name = "helix/runtime/queries/ato/${q}.scm";
      value.text = "; inherits: python\n";
    }) ["highlights" "indents" "textobjects"]);

    programs.helix = {
      enable = true;
      package = pkgs.helix;
      defaultEditor = true;

      settings = {
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
        language-server.harper-ls = {
          command = "harper-ls";
          args = ["--stdio"];
          config.harper-ls.dialect = "British";
        };
        language-server.ato = {
          command = "ato";
          args = ["lsp" "start"];
        };
        language = [
          {
            name = "ato";
            scope = "source.ato";
            file-types = ["ato"];
            roots = ["ato.yaml"];
            grammar = "python";
            comment-token = "#";
            indent = {
              tab-width = 4;
              unit = "    ";
            };
            language-servers = ["ato"];
          }
          {
            name = "markdown";
            language-servers = ["marksman" "markdown-oxide" "harper-ls"];
          }
          {
            name = "git-commit";
            language-servers = ["harper-ls"];
          }
          {
            name = "text";
            scope = "text.plain";
            file-types = ["txt"];
            roots = [];
            language-servers = ["harper-ls"];
          }
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
