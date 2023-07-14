{ config, pkgs, ... }:



{
  home.packages = [ pkgs.stow ];

  programs.fish = {
    shellAliases = {
      lsx = "ls -la";
    };
  };
}
