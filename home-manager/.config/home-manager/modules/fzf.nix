{ config, pkgs, ... }:

{
  home.packages = [ pkgs.fzf ];
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };
}
