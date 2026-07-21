{
  pkgs,
  inputs,
  ...
}: {
  flake.homeModules.discord = {pkgs, ...}: {
    imports = [inputs.nixcord.homeModules.nixcord];

    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.permittedInsecurePackages = ["openssl-1.1.1w"];

    # stylix would otherwise inject its own generated theme and enable it over system24
    stylix.targets.nixcord.enable = false;

    programs.nixcord = {
      enable = true;

      discord.enable = false;
      equibop.enable = true;

      user = "simeon";

      config.themeLinks = ["https://refact0r.github.io/system24/theme/flavors/system24-rose-pine.theme.css"];
      # equicord only applies links listed in enabledThemeLinks, unlike vanilla vencord
      config.enabledThemeLinks = ["https://refact0r.github.io/system24/theme/flavors/system24-rose-pine.theme.css"];

      config.plugins = {
        accountPanelServerProfile.enable = true;
        alwaysTrust.enable = true;
        anonymiseFileNames.enable = true;
        betterGifPicker.enable = true;
        betterInvites.enable = true;
        betterSessions.enable = true;
        betterSettings.enable = true;
        betterUploadButton.enable = true;
        biggerStreamPreview.enable = true;
        characterCounter.enable = true;
        clearUrls.enable = true;
        disableCallIdle.enable = true;
        disableDeepLinks.enable = true;
        equicordHelper.enable = true;
        experiments.enable = true;
        fakeNitro.enable = true;
        fakeProfileThemes.enable = true;
        favoriteEmojiFirst.enable = true;
        favoriteGifSearch.enable = true;
        favouriteAnything.enable = true;
        fixCodeblockGap.enable = true;
        forceOwnerCrown.enable = true;
        gameActivityToggle.enable = true;
        gifCollections.enable = true;
        gifMaker = {
          enable = true;
          lastWidth = 849;
          lastHeight = 720;
          lastCaptionMode = "caption";
          lastCaptionText = "edawat";
          lastBubbleTipBase = 0.0;
        };
        homeTyping.enable = true;
        ignoreCalls.enable = true;
        iLoveSpam.enable = true;
        imageFilename.enable = true;
        imageLink.enable = true;
        imageZoom = {
          enable = true;
          size = 4120.0;
          zoom = 3.3999999999999995;
        };
        memberCount.enable = true;
        messageLogger.enable = true;
        messageLoggerEnhanced = {
          enable = true;
        };
        messageTranslate = {
          enable = true;
          autoTranslate = false;
        };
        moyai.enable = true;
        newPluginsManager.enable = true;
        noMiddleClickPaste.enable = true;
        noNitroUpsell.enable = true;
        noPushToTalk.enable = true;
        notificationVolume.enable = true;
        noTypingAnimation.enable = true;
        questify = {
          enable = true;
          disableQuestsEverything = true;
          questButtonBadgeCount = 15;
        };
        reviewDb.enable = true;
        saveFavoriteGifs.enable = true;
        serverInfo.enable = true;
        showConnections.enable = true;
        showHiddenChannels.enable = true;
        showHiddenThings.enable = true;
        showMeYourName.enable = true;
        tenorGifSearch.enable = true;
        themeAttributes.enable = true;
        themeLibrary.enable = true;
        userVoiceShow.enable = true;
        volumeBooster.enable = true;
        webContextMenus.enable = true;
        webKeybinds.enable = true;
        whoReacted.enable = true;
        whosWatching.enable = true;
      };

      extraConfig.plugins = {
        BetterGifLoad = {
          enable = true;
          gifQuality = 1;
        };
      };
    };

    # environment.systemPackages = [
    #   pkgs.equibop
    # ];
  };
}
