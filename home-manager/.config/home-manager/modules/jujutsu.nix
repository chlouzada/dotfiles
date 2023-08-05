{ config, pkgs, ... }:

{
  home.packages = [ pkgs.jujutsu ];
  programs.jujutsu = {
    enable = true;
    enableFishIntegration = true;
  };
}
