{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "windows" ''
        sudo grub-reboot 2 && sudo reboot now
    '')
  ];
}
