{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "install" ''

apps="vscode discord brave i3wm"

vscode() {
    wget -O /tmp/vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    sudo apt install /tmp/vscode.deb
    rm /tmp/vscode.deb
}


discord() {
    wget -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb"
    sudo apt install /tmp/discord.deb
    rm /tmp/discord.deb
}

brave() {
    sudo apt install curl
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update
    sudo apt install brave-browser
}

i3wm() {
    /usr/lib/apt/apt-helper download-file https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2023.02.18_all.deb keyring.deb SHA256:a511ac5f10cd811f8a4ca44d665f2fa1add7a9f09bef238cdfad8461f5239cc4
    sudo apt install ./keyring.deb
    echo "deb http://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" | sudo tee /etc/apt/sources.list.d/sur5r-i3.list
    sudo apt update
    sudo apt install i3
}

selected=$(printf "$apps" | tr ' '  '\n' | fzf)
case $selected in
    "vscode")
        vscode
        ;;
    "discord")
        discord
        ;;
    "brave")
        brave
        ;;
    "i3wm")
        i3wm
        ;;
    *)
        echo "not impl"
        ;;
esac
    '')
  ];
}