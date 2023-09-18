{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "git-remote-replace" ''
      if [ $# -ne 2 ]; then
        echo "missing args"
        echo "usage: git-remote-replace {remote_name} {url}"
        exit 1
      fi
      remote=$1
      git remote rename $remote replaced-$remote-$(date +%s)
      git remote add $remote $2
    '')
  ];
}
