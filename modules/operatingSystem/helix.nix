{pkgs, ...}: {
  flake.homeModules.helix = {
    lib,
    pkgs,
    ...
  }: {
    programs.helix = {
      defaultEditor = true;
      enable = true;
      extraPackages = with pkgs; [
        nixd
        alejandra
        rust-analyzer
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
            other-lines = "error";
          };
          completion-replace = true;
        };
      };
      languages = {
        language = [
          {
            name = "nix";
            auto-format = true;
            formatter = {
              command = "${pkgs.alejandra}/bin/alejandra";
            };
          }
        ];
      };
    };
  };
}
