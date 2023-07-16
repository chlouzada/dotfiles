{ config, pkgs, ... }:

{
  home.packages = [ pkgs.alacritty ];
  programs.alacritty = {
  enable = true;
    settings = {
      # font.size = 11;
      shell.program = "/usr/local/bin/fish";
    };
  };
}
