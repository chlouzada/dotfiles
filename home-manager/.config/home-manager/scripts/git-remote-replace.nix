{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "git-remote-replace" ''
      remote=$1
      git remote rename $remote replaced-$remote-$(date +%s)
      git remote add $remote $2
    '')
  ];
}
