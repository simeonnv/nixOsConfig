{ config, ... }:
{
  flake.modules.homeManager.base.programs.lazygit = {
    enable = true;
  };
}
