{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "dotfiles" ''
        if [[ $1 == "-h" || $1 == "--help" ]]; then
            echo "Usage: dotfiles [OPTIONS]"
            echo "Options:"
            echo "  -e, --edit     Open the dotfiles directory in VSCode"
            echo "  -u, --update   Update dotfiles from git repository"
            echo "  -h, --help     Show this help message"
        elif [[ $1 == "-e" || $1 == "--edit" ]]; then
            code ~/dotfiles
        elif [[ $1 == "-u" || $1 == "--update" ]]; then
            cd ~/dotfiles
            git pull
            cd -
        else
            home-manager switch
        fi
    '')
  ];
}
