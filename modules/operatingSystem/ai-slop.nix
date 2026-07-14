{pkgs, ...}: {
  flake.nixosModules.ai-slop = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.claude-code
    ];
  };
}
