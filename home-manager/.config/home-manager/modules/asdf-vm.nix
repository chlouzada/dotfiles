{ config, pkgs, ... }:

{
  home.packages = [ pkgs.asdf-vm ];

  home.file = {
    ".tool-versions".text = ''
      nodejs 18.16.1
      rust 1.71.1
    '';
  };
}
