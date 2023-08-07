{ config, pkgs, ... }:

{
  home.packages = [ pkgs.lazygit ];
  programs.lazygit = {
    enable = true;
  };
}
