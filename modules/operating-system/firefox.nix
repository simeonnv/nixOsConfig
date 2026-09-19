{
  ownerProfile,
  inputs,
  ...
}: {
  flake.homeModules.firefox = {pkgs, ...}: let
    system = pkgs.stdenv.hostPlatform.system;
    addons = inputs.firefox-addons.packages.${system};
  in {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox.override {
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
          ];
        };

        settings = {
          "browser.toolbars.bookmarks.visibility" = "always";
          "extensions.autoDisableScopes" = 0;
        };
      };
    };

    stylix.targets.firefox = {
      profileNames = [ownerProfile.name];
      colorTheme.enable = true;
    };
  };
}
