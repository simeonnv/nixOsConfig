{
  ownerProfile,
  inputs,
  ...
}: {
  flake.homeModules.firefox = {pkgs, ...}: let
    system = pkgs.stdenv.hostPlatform.system;
    addons = inputs.firefox-addons.packages.${system};

    microslop = inputs.firefox-addons.lib.${system}.buildFirefoxXpiAddon {
      pname = "microslop";
      version = "0.0.5";
      addonId = "microslop@4o4";
      url = "https://addons.mozilla.org/firefox/downloads/file/4674546/microslop-0.0.5.xpi";
      sha256 = "sha256-Et6yL9LyqUWpUKzi4t5x56vihf/z+EXN5EVjXeU1Qdk=";
      meta = {};
    };
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
            microslop
            return-youtube-dislikes
            ublock-origin
            youtube-shorts-block
          ];
        };

        settings = {
          "browser.toolbars.bookmarks.visibility" = "always";
        };
      };
    };

    stylix.targets.firefox = {
      profileNames = [ownerProfile.name];
      colorTheme.enable = true;
    };
  };
}
