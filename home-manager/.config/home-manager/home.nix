{ config, pkgs, ... }:

let
  importDirs = dir:
    let
      modulePaths = builtins.filter (str: builtins.substring 0 1 str != "_")
        (builtins.attrNames (builtins.readDir dir));
    in map (n: "${dir}/${n}") modulePaths;

  moduleImports = importDirs ./modules;
  scriptImports = importDirs ./scripts;
  linuxOnlyImports = importDirs ./linux-only;

  osreleaseContents = builtins.readFile "/proc/sys/kernel/osrelease";
  isWSL = builtins.match ".*WSL2.*" osreleaseContents != null;
  
  imports = moduleImports ++ scriptImports  ++ (if isWSL then [] else linuxOnlyImports);
in
{
  imports = imports;

  home.username = "ch";
  home.homeDirectory = "/home/ch";
  
  programs = {
    bash = {
      enable = true;

      initExtra = "
        fish
      ";
    };

    lazygit = {
      enable = true;
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  home.packages = with pkgs; [
    openssh
    stow
    bat
    fd
    nixfmt
    gh
    ripgrep
    zip
    unzip
    apacheHttpd
    turso-cli
    yt-dlp
    lazydocker
    jq
    tldr
    asdf-vm
    kitty
    alacritty
    # curl-impersonate
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
  
  };

  nixpkgs.config = {
    allowUnfree = true;
    # allowUnsupportedSystem = true;
  };

  home.stateVersion = "23.05";
  programs.home-manager.enable = true;
}