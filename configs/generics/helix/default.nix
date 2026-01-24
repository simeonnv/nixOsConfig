{ config, pkgs, lib, ... }:

{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      nixd
      alejandra
      rust-analyzer
      lldb
    ];
    settings = {
      theme = "gruvbox";
      editor = {
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
      };
    };
    languages.language = [{
      name = "nix";
      auto-format = true;
      formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
      language-servers = [ "nixd" ];
    }];
  };
}
