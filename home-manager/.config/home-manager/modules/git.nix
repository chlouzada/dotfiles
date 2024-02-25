{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    userName = "chlouzada";
    userEmail = "chlouzada@gmail.com"; 

    aliases = {
      co = "checkout";
      ci = "commit";
    };

    extraConfig = {
      init.defaultBranch = "main";

      push.default = "simple".; 
      push.autoSetupRemote = true;

      url."git@github.com:".pushInsteadOf = "https://github.com";
      url."git@github.com:".insteadOf = "gh:";
    };
  };
}
