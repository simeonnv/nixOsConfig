{pkgs, ...}: {
  flake.nixosModules.zsh = {
    lib,
    pkgs,
    ...
  }: {
    programs.zsh.enable = true;
    users.defaultUserShell = pkgs.zsh;
  };

  flake.homeModules.zsh = {
    lib,
    pkgs,
    ...
  }: {
    programs.zsh = {
      enable = true;

      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      history = {
        size = 20000;
        save = 20000;
        ignoreDups = true;
        ignoreSpace = true;
      };

      shellAliases = {
        ll = "ls -al";
        la = "ls -A";
        l = "ls -CF";
        cl = "clear";
        update = "sudo nixos-rebuild switch --flake .";
        gs = "git status";
        gl = "git log --oneline --graph";
        cc = "claude --model fable --effort high --dangerously-skip-permissions --chrome --max-turns 20";
      };

      # oh-my-zsh = {
      #   enable = true;
      #   plugins = ["git" "docker" "kubectl" "z" "fzf"]; # choose what you need
      # };
    };

    programs.starship.enable = true;

    programs.zoxide.enable = true;
    programs.zoxide.enableZshIntegration = true;

    programs.fzf.enable = true;
    programs.fzf.enableZshIntegration = true;
  };
}
