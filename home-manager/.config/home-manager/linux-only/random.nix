{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ 
    clipcat
    rofi
    flameshot
    nitrogen
    mongodb-compass
    insomnia
  ];
}

