# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT
{
  ownerProfile,
  inputs,
  self,
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
    logo = self.lib.fravsLogo pkgs;
  in {
    home.file."${config.programs.firefox.configPath}/${config.programs.firefox.profiles.${ownerProfile.name}.path}/chrome/fravs.svg".source = "${logo}/favicon.svg";

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
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };

        userChrome = ''
          :root {
            --border-radius-small: 0 !important;
            --border-radius-medium: 0 !important;
            --border-radius-large: 0 !important;
            --tab-border-radius: 0 !important;
            --toolbarbutton-border-radius: 0 !important;
            --arrowpanel-border-radius: 0 !important;
            --urlbar-icon-border-radius: 0 !important;
          }
          * { border-radius: 0 !important; }

          .tab-icon-image[src="chrome://branding/content/icon32.png"] {
            content: url("fravs.svg") !important;
          }
        '';

        userContent = ''
          @-moz-document url-prefix("about:") {
            * { border-radius: 0 !important; }
          }

          @-moz-document url("about:newtab"), url("about:home") {
            .logo-and-wordmark .logo,
            .logo-and-wordmark .wordmark { display: none !important; }
            .logo-and-wordmark::after {
              content: "]T[";
              font-family: "MxPlus IBM VGA 8x16";
              font-size: 96px;
              color: #c4a7e7;
            }
          }
        '';
      };
    };

    stylix.targets.firefox = {
      profileNames = [ownerProfile.name];
      colorTheme.enable = true;
    };
  };
}
