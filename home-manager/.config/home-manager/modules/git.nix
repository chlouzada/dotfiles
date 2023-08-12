{ config, pkgs, ... }:

{
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
