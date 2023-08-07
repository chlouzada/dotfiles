{ config, pkgs, ... }:

{
  home.packages = [ pkgs.git ];
  programs.git = {
    enable = true;

    userName = "chlouzada";
    userEmail = "chlouzada@gmail.com"; 

    aliases = {
      co = "checkout";
      ci = "commit";
    };
  };
}
