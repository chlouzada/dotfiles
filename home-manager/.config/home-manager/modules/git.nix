{ config, pkgs, ... }:

{
  home.packages = [ pkgs.git ];
  programs.git = {
    enable = true;

    userName = "chlouzada";
    userEmail = "chlouzada@gmail.com"; 

    push = {
      default = "current";
      autoSetupRemote = true;
    };

    init = {
      defaultBranch = "main";
    };

  };
}
