{pkgs, ...}: {
  flake.nixosModules.git = {
    lib,
    pkgs,
    ...
  }: {
    environment.systemPackages = with pkgs; [git lazygit];
    programs.lazygit = {
      enable = true;
    };
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
      git = {
        enable = true;
        userName = "simeon";
        userEmail = "simmeon.nv@proton.me";
      };
      gh = {
        enable = true;
        gitCredentialHelper.enable = true;
      };
    };
  };
}
