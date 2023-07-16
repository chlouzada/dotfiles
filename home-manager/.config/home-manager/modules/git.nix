{ config, pkgs, ... }:

{
  home.packages = [ pkgs.git ];
  programs.git = {
    enable = true;
    userName = "JohnDoe";
    userEmail = "JohnDoe@JohnDoe.com"; 
  };
}
