{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "expose" ''
        if [ -z "$1" ]; then
            echo "Error: missing port"
            exit 1
        fi
        PORT=$1
        echo "ssh -R 80:localhost:$PORT nokey@localhost.run"
        sleep 1
        ssh -R 80:localhost:$PORT nokey@localhost.run
    '')
  ];
}
