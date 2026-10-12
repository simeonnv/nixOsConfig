{
  nixConfig = {
    extra-experimental-features = ["pipe-operators"];
  };

  inputs.self.submodules = true;
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-multiverse.url = "github:fzakaria/nixpkgs-multiverse";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";
    input-branches.url = "github:mightyiam/input-branches";

    disko.url = "github:nix-community/disko";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";

    deploy-rs.url = "github:serokell/deploy-rs";

    # driver stack (open-fprintd + python-validity) for the ThinkPad T480's 06cb:009a
    # fingerprint sensor; keeps its own nixpkgs pin, only tested against 24.11
    nixos-06cb-009a-fingerprint-sensor.url = "github:ahbnr/nixos-06cb-009a-fingerprint-sensor?ref=24.11";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-claude-code.url = "github:ryoppippi/nix-claude-code";

    nixcord.url = "github:4evy/nixcord";

    concord.url = "github:chojs23/concord";

    pi.url = "github:lukasl-dev/pi.nix";

    manifesto.url = "github:simeonnv/Manifesto";

    syphoria = {
      url = "git+https://codeberg.org/simeonnv/syphoria";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    ownerProfile = {
      name = "simeon";
      email = "simmeon.nv@proton.me";
      sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAz6cbpujcaBo5eAb4+c30kaD5T9wUXAtv5XS98BNACI simmeon.nv@proton.me";
    };
    goshoProfile = {
      name = "gosho";
      email = "geshoo46@gmail.com";
      sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOl+LmY2Pu7AeBrC5z4nK7bEPF0ylw4vOg8F7kgk44gz geshoo46@gmail.com";
    };
    sashoProfile = {
      name = "sasho";
      email = "SashkoV2@proton.me";
      sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHFb8GzWv9pej52qpJkPYXGkNYzFMCwRfefN3CYE3Zhl SashkoV2@proton.me";
    };
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        (inputs.import-tree ./modules)
        inputs.home-manager.flakeModules.home-manager
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem = {system, ...}: {
        _module.args.pkgs-stable = import inputs.nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };

        _module.args.pkgs-multiverse = inputs.nixpkgs-multiverse.lib.mkMultiverse {
          inherit system;
          config.allowUnfree = true;
        };
      };

      _module.args = {
        inherit ownerProfile goshoProfile sashoProfile;
      };
    };
}
