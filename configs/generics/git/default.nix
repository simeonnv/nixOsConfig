{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;

    userName  = "Simeon";                    
    userEmail = "simmeon.nv@proton.me";

    ignores = [
      "*~"
      ".DS_Store"
      ".direnv"
      "result"
      "result-*"
      ".envrc"
    ];

    extraConfig = {
      init.defaultBranch = "main";
      core.editor       = "helix";            
      core.autocrlf     = "input";           
      pull.rebase       = true;
      rebase.autosquash = true;
      merge.conflictStyle = "zdiff3";        

      url."https://github.com/".insteadOf   = [ "gh:" "github:" ];
      url."git@github.com:".pushInsteadOf   = "https://github.com/";

      log.decorate      = "short";
      diff.colorMoved   = "default";
    };

  };

  home.packages = with pkgs; [
    gh              
    git-credential-manager 
  ];

}
