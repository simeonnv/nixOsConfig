{pkgs, ...}: {
  flake.nixosModules.git = {
    lib,
    pkgs,
    ...
  }: {
    environment.systemPackages = with pkgs; [git];
    programs.git = {
      enable = true;
    };
  };

  flake.homeModules.git = {
    lib,
    pkgs,
    ...
  }: {
    programs = {
      lazygit = {
        enable = true;
      };
      git = {
        enable = true;
      };
      gh = {
        enable = true;
        gitCredentialHelper.enable = true;
      };
    };
  };
}
