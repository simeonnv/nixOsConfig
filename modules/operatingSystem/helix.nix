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
          lsp.display-messages = true;
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
