{inputs, ...}: {
  flake.nixosModules.ai-slop = {
    config,
    pkgs,
    lib,
    ...
  }: let
    hasStylix = config.stylix.enable or false;

    colors = config.lib.stylix.colors;
    c = colors.withHashtag;

    mix = a: b: t: let
      channel = k: let
        x = lib.toInt colors."${a}-rgb-${k}";
        y = lib.toInt colors."${b}-rgb-${k}";
        v = builtins.floor (x + (y - x) * t + 0.5);
      in
        lib.toLower (lib.fixedWidthString 2 "0" (lib.toHexString v));
    in "#${channel "r"}${channel "g"}${channel "b"}";

    piTheme = (pkgs.formats.json {}).generate "pi-stylix-theme.json" {
      name = "stylix";
      colors = {
        accent = c.base0D;
        border = c.base03;
        borderAccent = c.base0D;
        borderMuted = c.base02;
        success = c.base0B;
        error = c.base08;
        warning = c.base0A;
        muted = c.base04;
        dim = c.base03;
        text = c.base05;
        thinkingText = c.base04;

        selectedBg = c.base02;
        scrollbarTrack = c.base02;
        scrollbarThumb = c.base04;
        searchMatchBg = mix "base00" "base0A" 0.35;
        searchMatchText = c.base00;
        userMessageBg = c.base01;
        userMessageText = c.base05;
        customMessageBg = c.base01;
        customMessageText = c.base05;
        customMessageLabel = c.base0E;
        toolPendingBg = c.base01;
        toolSuccessBg = mix "base01" "base0B" 0.18;
        toolErrorBg = mix "base01" "base08" 0.18;
        toolTitle = c.base0D;
        toolOutput = c.base05;

        mdHeading = c.base0A;
        mdLink = c.base0D;
        mdLinkUrl = c.base04;
        mdCode = c.base0C;
        mdCodeBlock = c.base05;
        mdCodeBlockBorder = c.base03;
        mdQuote = c.base04;
        mdQuoteBorder = c.base03;
        mdHr = c.base03;
        mdListBullet = c.base0C;

        toolDiffAdded = c.base0B;
        toolDiffRemoved = c.base08;
        toolDiffContext = c.base04;

        syntaxComment = c.base03;
        syntaxKeyword = c.base0E;
        syntaxFunction = c.base0D;
        syntaxVariable = c.base08;
        syntaxString = c.base0B;
        syntaxNumber = c.base09;
        syntaxType = c.base0A;
        syntaxOperator = c.base05;
        syntaxPunctuation = c.base04;

        thinkingOff = c.base03;
        thinkingMinimal = c.base04;
        thinkingLow = c.base0C;
        thinkingMedium = c.base0D;
        thinkingHigh = c.base0E;
        thinkingXhigh = c.base09;
        thinkingMax = c.base08;

        bashMode = c.base09;
      };
    };

    piExtensions = pkgs.buildNpmPackage {
      pname = "pi-extensions";
      version = "0";
      src = ./pi-packages;
      npmDepsHash = "sha256-0CfOfmTYtMEnjCEsFdz6gAre8VcNCJRPd/r8a7XNATE=";

      dontNpmBuild = true;

      npmFlags = ["--legacy-peer-deps"];

      nativeBuildInputs = [pkgs.autoPatchelfHook];
      buildInputs = [pkgs.stdenv.cc.cc.lib pkgs.zlib];

      installPhase = ''
        runHook preInstall
        mkdir -p $out
        cp -r node_modules package.json package-lock.json $out/
        runHook postInstall
      '';
    };

    piPackage = name: "${piExtensions}/node_modules/${name}";
  in {
    imports = [inputs.pi.nixosModules.default];

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) ["claude"];
    nixpkgs.overlays = [inputs.nix-claude-code.overlays.default];
    environment.systemPackages = [
      pkgs.claude-code
    ];

    nix.settings = {
      extra-substituters = [
        "https://pi.cachix.org"
        "https://nix-community.cachix.org"
      ];
      extra-trusted-public-keys = [
        "pi.cachix.org-1:lGeoGJaZ5ZDabuRzkcD5EBTNnDM4HJ1vqeOxlWk1Flk="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    programs.pi.coding-agent = {
      enable = true;

      rules = ''Do not ever commit on git. Always ask before doing a change. Don't ever push to prod.'';

      themes = lib.optional hasStylix piTheme;

      settings =
        {
          defaultProvider = "anthropic";
          defaultModel = "claude-fable-5-1";
          defaultThinkingLevel = "high";

          packages = map piPackage [
            "@bytetrue/pi-web-search"
            "@ff-labs/pi-fff"
            "@sreetej510/pi-usage"
            "pi-lens"
            "pi-mcp-adapter"
            "pi-mono-clear"
            "@gotgenes/pi-anthropic-auth"
            "@narumitw/pi-lsp"
            "@aliou/pi-processes"
          ];
        }
        // lib.optionalAttrs hasStylix {theme = "stylix";};

      # jail.enable = true;
    };
  };
}
