{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ clipcat rofi nitrogen ];
}

