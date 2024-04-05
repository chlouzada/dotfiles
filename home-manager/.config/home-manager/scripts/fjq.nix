

{ config, pkgs, ... }:

{
  home.packages = with pkgs;
    [
      (pkgs.writeShellScriptBin "fjq" ''
        if [[ -z $1 ]] || [[ $1 == "-" ]]; then
            input=$(mktemp)
            trap 'rm -f "$input"' EXIT
            cat /dev/stdin > "$input"
        else
            input=$1
        fi

        echo "" \
            | ${fzf}/bin/fzf --disabled \
                --preview-window='up:90%' \
                --print-query \
                --preview "${jq}/bin/jq --color-output -r {q} $input"
                
      '')
    ];
}
