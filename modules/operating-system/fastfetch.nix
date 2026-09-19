{pkgs, ...}: {
  flake.nixosModules.fastfetch = {
    lib,
    pkgs,
    ...
  }: {
    programs.bash.interactiveShellInit = ''
      fastfetch
    '';
    programs.zsh.interactiveShellInit = ''
      fastfetch
    '';
    programs.fish.interactiveShellInit = ''
      fastfetch
    '';
  };

  flake.homeModules.fastfetch = {
    lib,
    pkgs,
    ...
  }: {
    programs.fastfetch = {
      enable = true;
    };
  };
}
