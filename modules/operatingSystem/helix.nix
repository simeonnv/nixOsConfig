{pkgs, ...}: {
  flake.homeModules.helix = {
    lib,
    pkgs,
    ...
  }: let
    yazi-picker = pkgs.writeShellScript "yazi-picker.sh" ''
      paths=$(${pkgs.yazi}/bin/yazi "$2" --chooser-file=/dev/stdout | while read -r; do printf "%q " "$REPLY"; done)

      if [[ -n "$paths" ]]; then
        ${pkgs.zellij}/bin/zellij action toggle-floating-panes
        ${pkgs.zellij}/bin/zellij action write 27 # send <Escape> key
        ${pkgs.zellij}/bin/zellij action write-chars ":$1 $paths"
        ${pkgs.zellij}/bin/zellij action write 13 # send <Enter> key
      else
        ${pkgs.zellij}/bin/zellij action toggle-floating-panes
      fi
    '';
  in {
    programs.helix = {
      defaultEditor = true;
      enable = true;
      extraPackages = with pkgs; [
        nixd
        alejandra
        rust-analyzer
        omnisharp-roslyn
        netcoredbg
        taplo
        yazi
      ];
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
        keys.normal = {
          # "C-y" = [
          #   ":sh rm -f /tmp/unique-file"
          #   ":insert-output yazi '%{buffer_name}' --chooser-file=/tmp/unique-file"
          #   ":insert-output echo \"\\x1b[?1049h\\x1b[?2004h\" > /dev/tty"
          #   ":open %sh{cat /tmp/unique-file}"
          #   ":redraw"
          # ];
          # [keys.normal]
          C-y = ":sh zellij run -n Yazi -c -f -x 10%% -y 10%% --width 80%% --height 80%% -- bash ${yazi-picker} open %{buffer_name}";
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
