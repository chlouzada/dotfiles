{ config, pkgs, ... }:

let
  osreleaseContents = builtins.readFile "/proc/sys/kernel/osrelease";
  isWSL = builtins.match ".*WSL2.*" osreleaseContents != null;
in
{
  programs.alacritty = {
    enable = !isWSL;
    settings = {
      # font.size = 11;
      # shell.program = "/usr/local/bin/fish";
    };
  };
}

