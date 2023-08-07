{ config, pkgs, ... }:

{
  home.packages = [ pkgs.asdf-vm ];
}
