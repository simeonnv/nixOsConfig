{pkgs, ...}: {
  flake.nixosModules.git = {
    lib,
    pkgs,
    ...
  }: {
    environment.systemPackages = [pkgs.git-credential-manager pkgs.git];
    programs.git = {
      enable = true;
      config = {
        credential.helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
        credential.credentialStore = "secretservice";
      };
    };
  };
}
