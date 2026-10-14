{
  ownerProfile,
  inputs,
  ...
}: {
  flake.homeModules.firefox = {
    pkgs,
    lib,
    config,
    ...
  }: let
    system = pkgs.stdenv.hostPlatform.system;
    addons = inputs.firefox-addons.packages.${system};
    syphoria = inputs.syphoria.packages.${system}.extension;
    browser = config.programs.firefox.finalPackage;
  in {
    home.packages = lib.optional (browser.meta.mainProgram != "firefox") (
      pkgs.runCommand "firefox-alias" {} ''
        mkdir -p $out/bin
        ln -s ${lib.getExe browser} $out/bin/firefox
      ''
    );

    programs.firefox = {
      enable = true;
      configPath = ".mozilla/firefox";
      package = pkgs.firefox-esr.override {
        extraPrefs = ''
          lockPref("identity.sync.tokenserver.uri", "https://sync.fravs.org/1.0/sync/1.5");
        '';
      };
      profiles.${ownerProfile.name} = {
        name = ownerProfile.name;
        isDefault = true;

        extensions = {
          force = true;
          packages = with addons; [
            foxyproxy-standard
            istilldontcareaboutcookies
            return-youtube-dislikes
            ublock-origin
            syphoria
          ];
        };

        settings = {
          "browser.toolbars.bookmarks.visibility" = "always";
          "extensions.autoDisableScopes" = 0;
          "xpinstall.signatures.required" = false;
        };
      };
    };

    stylix.targets.firefox = {
      profileNames = [ownerProfile.name];
      colorTheme.enable = true;
    };
  };
}
