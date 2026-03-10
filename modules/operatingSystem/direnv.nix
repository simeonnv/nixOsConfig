{pkgs, ...}: {
  flake.homeModules.direnv = {
    lib,
    pkgs,
    ...
  }: {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;

      config = {
        global = {
          warn_timeout = "30s";
        };
        whitelist = {
          prefix = ["~/code"];
        };
      };

      stdlib = ''
        use_nix() {
          direnv_load nix-shell --silent "$@"
        }
      '';
    };
  };
}
