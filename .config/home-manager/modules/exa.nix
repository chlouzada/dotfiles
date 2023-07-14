{ config, pkgs, ... }:

{
  home.packages = [ pkgs.exa ];
  programs.exa = {
    enable = true;
    enableAliases = true;
  };
}
