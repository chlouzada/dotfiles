{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "dotfiles" ''
        if [[ $1 == "-h" || $1 == "--help" ]]; then
            echo "Usage: dotfiles [OPTIONS]"
            echo "Options:"
            echo "  -e, --edit     Open the dotfiles directory in VSCode"
            echo "  -p, --pull     Pull remote changes"
            echo "  -P, --push     Push remote changes"
            echo "  -h, --help     Show this help message"
        elif [[ $1 == "-e" || $1 == "--edit" ]]; then
            code ~/dotfiles
        elif [[ $1 == "-p" || $1 == "--pull" ]]; then
            cd ~/dotfiles
            git pull
            cd -
        elif [[ $1 == "-P" || $1 == "--push" ]]; then
            cd ~/dotfiles
            git push
            cd -
        else
            home-manager switch
        fi
    '')
  ];
}
