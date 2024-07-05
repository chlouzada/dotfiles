{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ clipcat rofi flameshot ];
}

