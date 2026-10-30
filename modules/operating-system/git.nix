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
        settings = {
          user.name = "simeon";
          user.email = "simmeon.nv@proton.me";
          pull.rebase = false;
        };
      };
      gh = {
        enable = true;
        gitCredentialHelper.enable = true;
      };
    };
  };
}
