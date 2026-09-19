{pkgs, ...}: {
  flake.nixosModules.rust = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      pkg-config
      cmake
      gcc
      automake
      llvm
      libclang

      cargo
      rustc
      rustfmt
      clippy
      rust-analyzer
      sqlx-cli
      cargo-info
    ];
  };
}
