{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;

    initExtra = "
      fish
    ";
  };
}
