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
            youtube-shorts-block
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
